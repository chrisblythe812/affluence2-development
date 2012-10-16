require "base64"
class User < ActiveRecord::Base

  attr_accessible :unread_messages_counter, :invitation_email_body
  attr_accessor :invitation_email_body


  has_one :profile, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :sent_messages, :foreign_key => "sender_id", :class_name => "Message"
  has_many :received_messages, :foreign_key => "recipient_id", :class_name => "Message"
  has_and_belongs_to_many :promotions
  has_many :connections
  has_many :connections_activities, :class_name => "Activity", :finder_sql => Proc.new {
    #    ids=[]
    #    ids<<id
    #    self.connections.each{|x| ids<<x.friend.id}
    #    temp = ''
    #    ids.each_index{|x|
    #      temp =   temp + ids[x].to_s
    #      temp = temp + ',' unless x==ids.length-1
    #    }
    #    %Q{
    #      SELECT  *
    #      FROM activities
    #      WHERE user_id IN (#{id})
    #      ORDER BY updated_at DESC
    #      LIMIT 6 OFFSET 0;
    #    }
  }
  has_many :invitations, :class_name => "InvitationHistory"
  has_many :contacts

  has_many :verfication, :dependent => :destroy

  def disconnect_with_user(friend_id)
    connection1 = Connection.where("user_id=? and friend_id=?", id, friend_id)
    connection2 = Connection.where("user_id=? and friend_id=?", friend_id, id)
    no_of_records_deleted = Connection.delete(connection1 + connection2)
    return no_of_records_deleted == 2
  end

  def connections_activities(last_activity = false)
    ids=[]
    ids << self.id
    self.connections.each { |x| ids << x.friend.id }
    activities = []
    temp = false

    pro_activities = []
    begin
      if !last_activity && pro_activities.blank?
        activities = Activity.where(:user_id => ids).order("id desc").limit(20)
      elsif last_activity && !temp
        activities = Activity.where(:user_id => ids).order("id desc").where("id < ?", last_activity.to_i).limit(20)
        temp = true
      elsif !pro_activities.blank?
        activities = Activity.where(:user_id => ids).order("id desc").where("id < ?", pro_activities.last.id).limit(20)
      end

      break if activities.blank?

      activities.each do |activity|
        break if (pro_activities.length == 7)
        next if (activity.resource_type == 'PhotoStream') && (activity.resource.photos.count < 1)
        next unless (!activity.resource.nil?)
        privacy = activity.user.profile.privacy_setting
        if self == activity.user
          pro_activities << activity
        else
          pro_activities << activity if [0, 1].include? (privacy.send(PrivacySetting::OPTS[activity.resource_type]))
        end
      end
      temp = true

    end while pro_activities.length < 7

    pro_activities
  end

  def activities_by_privacy_settings(current_user, last_activity = false)
    ids = []
    self.connections.each { |x| ids << x.friend.id }

    activity = nil
    if last_activity
      activity = self.activities.find(last_activity.to_i)
    end

    activities = []
    is_friend = ids.include?(current_user.id)

    begin
      activity = activity ? self.activities.previous(activity).first : self.activities.last
      break unless activity
      next if activity.resource.nil?
      next if (activity.resource_type == 'PhotoStream') && (activity.resource.photos.count < 1)
      privacy = activity.user.profile.privacy_setting

      if activity.resource_type == 'Profile'
        #activities << activity
      else
        if is_friend
          activities << activity if [0, 1].include?(privacy.send(PrivacySetting::OPTS[activity.resource_type]))
        elsif (privacy.send(PrivacySetting::OPTS[activity.resource_type]) == 0)
          activities << activity
        end
      end

    end while activities.length < 7

    activities

  end

  has_many :payments
  has_many :pending_alert_notifications, :class_name => NotificationTracker, :conditions => "channel = 'alert' and status = 'pending'"

  has_many :promotions_users
  has_many :promotions, :through => :promotions_users


  has_many :vincompass_shares

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :profile_attributes, :card_number, :expiry_month, :expiry_year, :zip_code, :plan, :role, :status, :points, :created_at, :updated_at
  accepts_nested_attributes_for :profile


  attr_accessor :card_number, :expiry_month, :expiry_year, :zip_code

  validates_presence_of :plan

  after_create :create_user_in_mailchimp
  after_save :create_or_update_profile

  def create_or_update_profile
    if self.profile.nil?
      self.build_profile(:first_name => "first name", :last_name => "last name", :city => "city", :country => "US").save!
    end
  end

  def create_user_in_mailchimp
    #should create user only when user is in active state
    MailChimp.add_user(self)
  end

  def superadmin?
    self.role == 'superadmin'
  end

  def has_admin_access?
    self.role == 'superadmin' || self.role == 'operator'
  end


  scope :all_members, :conditions => ['role not like ?', 'superadmin']
  scope :active_members, :conditions => ['role not like ? and status like ?', 'superadmin', "active"]
  scope :suspended_members, :conditions => ['role not like ? and status like ? ', 'superadmin', "suspended"]
  scope :deleted_members, :conditions => ['role not like ? and status like ? ', 'superadmin', "deleted"]

  scope :first_name_or_last_name, lambda { |query| {:conditions => ['role not like ? and status like ? email like ? ', 'superadmin', "deleted", query]} }
  scope :registered_users, where("(invited_by_id is null) or (invited_by_id is not null and invitation_sent_at is not null)")


  def first_name_or_last_name

  end
  state_machine :plan, :initial => :free do
    after_transition :on => [:monthly, :yearly] do |user, transition|
      inviter = user.invited_by
      if inviter.present?
        inviter_invitation_history = inviter.invitations.where(:status => 2, :email => user.email).first

        if inviter_invitation_history
          case transition.to
          when "Monthly", "Yearly"
            User.increment_counter(:points, inviter.id)
          end
          inviter_invitation_history.update_attributes(:status => 3)
        end
      end

    end


    event :monthly do
      transition :free => :Monthly
    end
    event :yearly do
      transition :free => :Yearly
    end  end


  has_permalink :permalink_name, :update => true

  state_machine :status, :initial => :active do

    after_transition :on => :suspended, :do => :suspended_from_mail_chimp
    after_transition :on => :unsuspended, :do => :add_user_on_mail_chimp
    after_transition :on => :deleted, :do => :clear_connections_conversations

    event :suspended do
      transition :active => :suspended
    end
    event :unsuspended do
      transition :suspended => :active
    end

    event :deleted do
      transition :active => :deleted
    end
  end

  def suspended_from_mail_chimp
    MailChimp.unsubscribe_user(self)
  end

  def add_user_on_mail_chimp
    MailChimp.add_user(self)
  end


  def active_for_authentication?
    super && account_active?
  end

  def account_active?
    status=='active'
  end

  def account_suspended?
    status=='suspended'
  end

  def clear_connections_conversations
    delete_all_connections
    update_all_conversations
  end


  def permalink_name
    profile_name = name
    begin
      PermalinkFu.escape(profile_name)
    rescue #syntax_error
      profile_name = Base64.encode64(profile_name)
    end
    profile_name
  end


  def name
    self.profile.nil? ? '' : self.profile.name
  end

  def with_profile
    self.build_profile
    self
  end

  def plan_amount
    return 50 if plan == 'Monthly'
    return 450 if plan == 'Yearly'
    return 0 if plan == 'free'
  end


  def plan_period_in_days
    return 30 if plan == 'Monthly'
    return 365 if plan == 'Yearly'
    return 0 if plan == 'free'
  end


  def self.create_user_with_braintree_id(user, braintree_customer_id)
    user[:braintree_customer_id] = braintree_customer_id
    user = User.new(user)
    user.save
    create_or_update_subscription(user)
    user
  end

  def update_user_with_plan_and_braintree_id(plan, braintree_customer_id)
    self.plan = !plan.blank? ? plan : 'Monthly'
    self.braintree_customer_id = braintree_customer_id if !braintree_customer_id.blank?
    self.save
    create_or_update_subscription(self)
  end


  def change_current_plan(new_plan, braintree_customer_id=nil)
    update_user_with_plan_and_braintree_id(new_plan, braintree_customer_id)
  end

  def create_or_update_subscription(user)
    user_subscription = SubscriptionFeeTracker.where(:user_id => user.id).not_completed.last
    if !user_subscription.blank?
      user_subscription.update_attributes(:amount => user.plan_amount)
    else
      SubscriptionFeeTracker.schedule(user)
    end
  end


  def self.create_or_update_subscription(user)
    user_subscription = SubscriptionFeeTracker.where(:user_id => user.id).not_completed.last
    if !user_subscription.blank?
      user_subscription.update_attributes(:amount => user.plan_amount)
    else
      SubscriptionFeeTracker.schedule(user)
    end
  end


  FIELDS = [:first_name, :last_name, :phone, :website, :company, :fax, :addresses, :credit_cards, :custom_fields]
  attr_accessor *FIELDS
  attr_accessible :braintree_customer_id

  def has_payment_info?
    braintree_customer_id
  end

  def with_braintree_data!
    return self unless has_payment_info?
    braintree_data = Braintree::Customer.find(braintree_customer_id)

    FIELDS.each do |field|
      send(:"#{field}=", braintree_data.send(field))
    end
    self
  end

  def default_credit_card
    return unless has_payment_info?

    credit_cards.find { |cc| cc.default? }
  end

  def delete_all_connections
    Connection.delete_all(["user_id=? OR friend_id=?", self.id, self.id])
  end

  def update_all_conversations(bool = true)
    ConversationMetadatum.where(:user_id => self.id).each do |meta|
      meta.update_attribute(:archived, bool)
    end
  end

  def cancel_membership
    SubscriptionFeeTracker.delete_all(["user_id=? AND status = ?", self.id, 'pending'])
    result = Braintree::Customer.delete(self.braintree_customer_id)
    if result.success?
      puts "customer successfully deleted"
    else
      raise "this should never happen"
    end
    self.update_attributes(:plan => 'free', :braintree_customer_id => '')
  end

  def generate_token
    self.token = SecureRandom.hex(16)
    self.token_expiration_date = 60.days.from_now
    self.save(:validate => false)
    self.token
  end

  def valid_api_token?
    self.token.present? && self.token_expiration_date > Date.today
  end


  def verifications_with_state(state)
    verfication.where(:status => state)
  end


  def submitted_for_verification?
    !verifications_with_state('submited').blank?
  end

  def concierge_calls_count
    concierge_calls.count
  end

  def concierge_calls
    promotions_users.where("promotions.promotionable_type like 'Concierge' ").joins('left join promotions on promotions.id = promotions_users.promotion_id')
  end

  #invite methods
  def invitation_expired?
    if invitation_sent_at.present?
      return (Time.now - invitation_sent_at) > User.invite_for.to_i
    end
    return true
  end
  def has_imported_contacts?(provider)
    contact = contacts.where(:provider => provider).limit(1).first
    return contact.present?
  end
  def can_receive_invitation?
    return invited_by.present? && invitation_accepted_at.nil? && invitation_expired?
  end

  def can_view?(profile, type = nil)
    return false if PrivacySetting::OPTS[type].nil?
    opts = profile.privacy_setting.send(PrivacySetting::OPTS[type])
  
    return (!opts.nil? && ((opts == PrivacySetting::EVERYONE) || ((opts == PrivacySetting::CONTACTS_ONLY) && (Connection.are_connected?(self, profile.user)))))
  end



  def self.concierge_users
   User.find_by_sql("select * from users where id in(
SELECT user_id FROM promotions_users left join promotions on promotions.id = promotions_users.promotion_id
 WHERE (promotions.promotionable_type like 'Concierge')
)")
  end



end

require "base64"
class User < ActiveRecord::Base

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
  def connections_activities
    ids=[]
    ids<<self.id
    self.connections.each{|x| ids<<x.friend.id}

    activities = []
    begin
      activity = activity ? Activity.previous(activity).first : Activity.last
      break unless activity
      next unless ids.include? activity.user.id
      privacy =  activity.user.profile.privacy_setting
      if activity.resource_type == 'Profile'
        #activities << activity
      else
        activities << activity if [0, 1].include? (privacy.send(Activity::OPTS[activity.resource_type]))
      end

    end while activities.length < 7

    activities
  end

def activities_by_privacy_settings(current_user)
    ids = []
    self.connections.each{|x| ids<<x.friend.id}

    activities = []
    is_friend = ids.include?(current_user.id)
         
    begin
      activity = activity ? Activity.previous(activity).first : Activity.last
      break unless activity
      next unless activity.user == self
      privacy =  activity.user.profile.privacy_setting

      if activity.resource_type == 'Profile'
        #activities << activity
      else
        if is_friend
          activities << activity if [0,1].include?(privacy.send(Activity::OPTS[activity.resource_type])) 
        elsif (privacy.send(Activity::OPTS[activity.resource_type]) == 0)
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



  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :profile_attributes, :card_number, :expiry_month, :expiry_year, :zip_code, :plan, :role, :status, :created_at, :updated_at
  accepts_nested_attributes_for :profile


  attr_accessor :card_number, :expiry_month, :expiry_year, :zip_code

  validates_presence_of :plan

   after_create :create_user_in_mailchimp

  def create_user_in_mailchimp
    #should create user only when user is in active state
  MailChimp.add_user(self)
  end

  def superadmin?
    self.role == 'superadmin' 
  end



  scope :all_members, :conditions => ['role not like ?', 'superadmin']
  scope :active_members, :conditions => ['role not like ? and status like ?', 'superadmin', "active"]
  scope :suspended_members, :conditions => ['role not like ? and status like ? ', 'superadmin', "suspended"]


  has_permalink :permalink_name, :update => false

  state_machine :status, :initial => :active do

    after_transition :on => :suspended, :do => :suspended_from_mail_chimp
    after_transition :on => :unsuspended, :do => :add_user_on_mail_chimp

    event :suspended do
      transition :active => :suspended
    end
    event :unsuspended do
      transition :suspended => :active
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


  def self.create_user_with_braintree_id(user,braintree_customer_id)
    user[:braintree_customer_id] = braintree_customer_id
    user = User.new(user)
    user.save
    create_or_update_subscription(user)
    user
  end

  def update_user_with_plan_and_braintree_id(plan,braintree_customer_id)
    self.plan = !plan.blank? ? plan : 'Monthly'
    self.braintree_customer_id = braintree_customer_id if !braintree_customer_id.blank?
    self.save
    create_or_update_subscription(self)
  end



  def change_current_plan(new_plan,braintree_customer_id=nil)
    update_user_with_plan_and_braintree_id(new_plan,braintree_customer_id)
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

  def archive_all_conversations!  
    ConversationMetadata.where(:user_id => self.id).each do |meta|
      meta.update_attribute(:archived, true)
    end
  end
end

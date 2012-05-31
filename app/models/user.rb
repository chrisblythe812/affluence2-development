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


  has_many :payments
  has_many :pending_alert_notifications, :class_name => NotificationTracker, :conditions => "channel = 'alert' and status = 'pending'"


  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :profile_attributes, :card_number, :expiry_month, :expiry_year, :zip_code, :plan, :role
  accepts_nested_attributes_for :profile


  attr_accessor :card_number, :expiry_month, :expiry_year, :zip_code

  validates_presence_of :plan



  def superadmin?
    self.role == 'superadmin' 
  end



  scope :members, :conditions => ['role = ?', 'member']

  has_permalink :name, :update => false

  state_machine :status, :initial => :active do
    event :suspended do
      transition :active => :suspended
    end
    event :unsuspended do
      transition :suspended => :active
    end
  end

  def active_for_authentication?
    super && account_active?
  end

  def account_active?
    status=='active'
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
    create_or_update_subscription
    user
  end

  def update_user_with_plan_and_braintree_id(plan,braintree_customer_id)
    self.plan = !plan.blank? ? plan : 'Monthly'
    self.braintree_customer_id = braintree_customer_id if !braintree_customer_id.blank?
    self.save
    create_or_update_subscription
  end



  def change_current_plan(new_plan,braintree_customer_id=nil)
    update_user_with_plan_and_braintree_id(new_plan,braintree_customer_id)
  end


  def create_or_update_subscription
    user_subscription = SubscriptionFeeTracker.where(:user_id => self.id).not_completed.last
    if !user_subscription.blank?
      user_subscription.update_attributes(:amount => self.plan_amount)
    else
      SubscriptionFeeTracker.schedule(self)
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
end

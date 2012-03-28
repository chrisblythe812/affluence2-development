class User < ActiveRecord::Base

  has_one :profile, :dependent => :destroy


  has_many :activities, :foreign_key => "user_id"
  
  has_many :sent_messages, :foreign_key => "sender_id", :class_name => "Message"
  has_many :received_messages, :foreign_key => "recipient_id", :class_name => "Message"
    has_and_belongs_to_many :promotions
  
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

  def with_profile
    self.build_profile
    self
  end

  scope :members, :conditions => ['role = ?', 'member']

  has_permalink :name, :update => true


  def name
  self.profile.name
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

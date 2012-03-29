class User < ActiveRecord::Base

  has_one :profile, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :sent_messages, :foreign_key => "sender_id", :class_name => "Message"
  has_many :received_messages, :foreign_key => "recipient_id", :class_name => "Message"
  has_and_belongs_to_many :promotions
  has_many :connections
  has_many :connections_activities, :class_name => "Activity", :finder_sql => Proc.new {
    ids=[]
    ids<<id
    self.connections.each{|x| ids<<x.id}
    temp = '' 
    ids.each_index{|x|
      temp =   temp + ids[x].to_s
      temp = temp + ',' unless x==ids.length-1
    }
    %Q{
      SELECT  *
      FROM activities
      WHERE user_id IN (#{id})
      ORDER BY updated_at DESC
      LIMIT 6 OFFSET 0;
    }
  }


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

  has_permalink :name, :update => true


  def name
    self.profile.name  
  end



end

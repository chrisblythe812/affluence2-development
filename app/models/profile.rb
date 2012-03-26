class Profile < ActiveRecord::Base
  belongs_to :user

  attr_accessible :first_name, :last_name,:city,:country


#  acts_as_taggable_on :interests, :expertises

  has_many :photos, :as => :photoable, :dependent => :destroy
#    has_one :photo_stream, :dependent => :destroy

  has_one :privacy_setting, :dependent => :destroy
  has_one :notification_setting, :dependent => :destroy
  has_many :activities, :as => :resource, :dependent => :destroy

 
  #accepts_nested_attributes_for :user
  #attr_accessible :user_attributes

  accepts_nested_attributes_for :privacy_setting
  attr_accessible :privacy_setting_attributes

  
  before_create :create_associated_records

  #TODO friends_profiles
  #  scope :friends_profiles, lambda { |user_id|
  #    joins(:user => :friendships).
  #    where("friendships.friend_id = ?", user_id)
  #  }

 validates_presence_of :first_name,:last_name,:city,:country

      
  #before_save :update_full_name

  def name
    #middle = middle_name.present? ? " #{middle_name} " : " "
    "#{first_name} #{last_name}"
  end

  def update_full_name
    self.full_name = name if (first_name_changed? || middle_name_changed? || last_name_changed?)
  end

  private

  def create_associated_records
   self.build_notification_setting
   self.build_privacy_setting
  end
end

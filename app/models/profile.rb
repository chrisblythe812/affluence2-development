class Profile < ActiveRecord::Base
  acts_as_taggable_on :interests, :expertises

  has_many :photos, :as => :photoable, :dependent => :destroy
  has_one :photo_stream, :dependent => :destroy

  belongs_to :user
  has_one :privacy_setting
  has_one :notification_setting
  has_many :activities, :as => :resource, :dependent => :destroy
 
  accepts_nested_attributes_for :user
  attr_accessible :user_attributes

  accepts_nested_attributes_for :privacy_setting
  attr_accessible :privacy_setting_attributes

  

  #TODO friends_profiles
  #  scope :friends_profiles, lambda { |user_id|
  #    joins(:user => :friendships).
  #    where("friendships.friend_id = ?", user_id)
  #  }
  attr_accessible :first_name, :middle_name, :last_name, :full_name, :city, :country,
    :phone, :bio, :title, :picture, :state, :company
      
  before_save :update_full_name

  def name
    middle = middle_name.present? ? " #{middle_name} " : " "
    "#{first_name}#{middle}#{last_name}"
  end

  def update_full_name
    self.full_name = name if (first_name_changed? || middle_name_changed? || last_name_changed?)
  end
end

class Promotion < ActiveRecord::Base
  has_many :photos, :as => :photoable, :dependent => :destroy
  belongs_to :promotionable, :polymorphic => true, :dependent => :destroy


  has_many :promotions_users
  has_many :users, :through => :promotions_users


  #has_and_belongs_to_many :users

  has_many :registered_members,  :class_name => 'PayablePromotion'

  accepts_nested_attributes_for :photos

  attr_accessible :user

  #validates_presence_of :promotionable

  def normal_image
    photos.find(:first, :conditions => " image_type = 'normal'")
  end

  def carousel_image
    photos.find(:first, :conditions => " image_type = 'carousel'")
  end

  def gallery_images
    photos.find(:all, :conditions => " image_type is null")
  end

  def offer_image
    photos.find(:first)
  end

  def active_registered_members
    registered_members.find(:all, :conditions => " users.id is not null",  :joins => "left join users on users.id = payable_promotions.user_id" )
  end

  def unique_registered_members
    registered_members.group("user_id").select("user_id, sum(total_tickets)")
  end

  def activate_promotion_for_member(user)
    PromotionsUser.create(:promotion_id => self.id, :user_id => user.id)
  end
end

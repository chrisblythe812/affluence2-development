class PromotionsUser < ActiveRecord::Base

  belongs_to :user
  belongs_to :promotion

  attr_accessible :user_id, :promotion_id



  scope :concierge, :conditions => "promotions.promotionable_type like 'Concierge' ",
        :joins => 'left join promotions on promotions.id = promotions_users.promotion_id'


end

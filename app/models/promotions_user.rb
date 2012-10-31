class PromotionsUser < ActiveRecord::Base

  belongs_to :user
  belongs_to :promotion

  attr_accessible :user_id, :promotion_id


  scope :concierge, :conditions => "promotions.promotionable_type like 'Concierge' ",
        :joins => 'left join promotions on promotions.id = promotions_users.promotion_id inner join profiles on profiles.user_id = promotions_users.user_id',
        :select => "promotions_users.user_id, max(promotions_users.created_at) AS created_at", :order => "max(promotions_users.created_at) desc" , :group => "promotions_users.user_id, profiles.first_name"


end

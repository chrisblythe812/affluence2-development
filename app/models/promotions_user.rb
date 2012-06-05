class PromotionsUser < ActiveRecord::Base

  belongs_to :user
  belongs_to :promotion

  attr_accessible :user_id,:promotion_id

end

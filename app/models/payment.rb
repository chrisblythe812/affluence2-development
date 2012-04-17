class Payment < ActiveRecord::Base


  belongs_to :user

  belongs_to :payable_promotion, :foreign_key => 'payable_id'

  default_scope :order => 'created_at DESC'

end

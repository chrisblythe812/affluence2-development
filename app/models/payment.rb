class Payment < ActiveRecord::Base


  belongs_to :user

  belongs_to :payable_promotion, :foreign_key => 'payable_id'

end

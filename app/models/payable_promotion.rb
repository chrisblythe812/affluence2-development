class PayablePromotion < ActiveRecord::Base

  belongs_to :user
  belongs_to :promotion


  def amount
    total_amount
  end

  def self.pending_payment(payment_object)
    Payment.where(:payable_id => payment_object.id, :payable_type => payment_object.class.name, :status => 'pending').last
  end
end

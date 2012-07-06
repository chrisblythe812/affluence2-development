class PayablePromotion < ActiveRecord::Base

  belongs_to :user
  belongs_to :promotion


  def amount
    total_amount
  end

  def self.pending_payment(payment_object)
    Payment.where(:payable_id => payment_object.id, :payable_type => payment_object.class.name, :status => 'pending').last
  end

  def self.create_event_promotion(promotion_params, event, user)
    payable_promotion = new(promotion_params)
    payable_promotion.price_per_ticket = event.price
    payable_promotion.user_id = user.id
    payable_promotion.promotion_id = event.promotion.id
    payable_promotion.total_amount = calculate_total_amount(promotion_params[:total_tickets], event.price)
    payable_promotion.save
    payable_promotion
  end


  def self.calculate_total_amount(total_tickets, price_per_ticket, discount=nil)
    total_amount = 0
    if !total_tickets.blank?
      total_amount = price_per_ticket*total_tickets.to_i
    end
    #todo add code for discounts
    total_amount
  end


end

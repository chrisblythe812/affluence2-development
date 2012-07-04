module OrdersHelper


  def order_type(type)
    if type == 'SubscriptionFeeTracker'
      content_tag("span", "Due's", :class => "label label-info")
    elsif type == 'PayablePromotion'
      content_tag("span", "Event", :class => "label label-success")
    end
  end

  def order_content(order)
    if order.payable_type == 'SubscriptionFeeTracker'
      "Monthly Membership Fee"
    elsif order.payable_type == 'PayablePromotion'
      if !order.payable_promotion.blank? && !order.payable_promotion.promotion.blank? && !order.payable_promotion.promotion.promotionable.blank?
        order.payable_promotion.promotion.promotionable.title
      else
        # todo
        'Event title'
      end

    end
  end

  def order_content_popup(order)
    if order.payable_type == 'SubscriptionFeeTracker'
      "Monthly Membership Fee"
    elsif order.payable_type == 'PayablePromotion'
      tickets = order.payable_promotion.total_tickets
      "#{tickets} Tickets have been booked "
    end
  end

end

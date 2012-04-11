module OrdersHelper





  def order_type(type)
      if type == 'SubscriptionFeeTracker'
        content_tag("span", "Due's", :class => "label label-info")
      else
        content_tag("span", "Event", :class => "label label-success")
      end
  end

  def order_content(order)
     if order.payable_type == 'SubscriptionFeeTracker'
      "Monthly Membership Fee"
     else
      "order message"
     end
  end

  def order_content_popup(order)
    if order.payable_type == 'SubscriptionFeeTracker'
      "Monthly Membership Fee"
    else
      "order message"
    end
  end

end

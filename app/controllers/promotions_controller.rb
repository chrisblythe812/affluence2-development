class PromotionsController < ApplicationController
  layout false

  def become_premium_member
    if params[:promotion] == 'event'
      event = Event.find(params[:id])
      @callback_url = confirm_events_url(:event_id => event.id)
    else
      @callback_url = confirm_offers_url
    end
  end


end

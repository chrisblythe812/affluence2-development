class PromotionsController < ApplicationController
  layout false

  def become_premium_member
    if params[:promotion] == 'event'
      event = Event.find(params[:id])
      @callback_url = confirm_events_url(:event_id => event.id)
    elsif params[:promotion] == 'offer'
      @callback_url = confirm_offers_url
      #elsif params[:promotion] == 'message'
      #@callback_url = confirm_user_conversations_url(params[:id])
    else
      @callback_url = confirm_user_conversations_url(params[:id])
    end
  end


end

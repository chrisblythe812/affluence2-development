class EventsController < ApplicationController
  def index
    @profile_tab = false
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def delete
  end

  def home_page_events
    get_latest
    render :partial => 'home_page_events'
  end

  def landing_page_events
    get_latest
    render :partial => 'landing_page_events'
  end

  def get_latest(max=3)
    @promotion_events = Promotion.find_all_by_promotionable_type('Event', :limit => max)
  end
end

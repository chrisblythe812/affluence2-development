class HomeController < ApplicationController

  before_filter :authenticate_user!, :update_unread_messages_count

  def index

  end


end

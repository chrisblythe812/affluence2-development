class WelcomeController < ApplicationController
  layout "welcome"
  def index
    render :text => "Welcome to Affluence"
  end
end

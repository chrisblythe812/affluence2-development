class OrdersController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_profile_navigation



  def index
   @orders = current_user.payments.where(:status => 'completed')
  end

end

class WinesharesController < ApplicationController

  before_filter :authenticate_user!
  def index
    @wine_shares = Kaminari.paginate_array(WineShare.all(:include => :vincompass_share).reverse).page(params[:page]).per(3)
  end


end

class ProfileController < ApplicationController
#  before_filter :authenticate_user!

  layout nil


  def index
    @new_members = User.find(:all, :order => "id desc", :limit => 5).reverse


  end


end

class VerficationsController < ApplicationController
  before_filter :authenticate_user!

  def new
  @verfication = Verfication.new
  end


  def create
    @verfication = Verfication.new(params[:verfication])
    if @verfication.save
      redirect_to profile_path(current_user.permalink)
    end

  end
end

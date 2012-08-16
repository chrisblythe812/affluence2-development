class VerficationsController < ApplicationController
  before_filter :authenticate_user!

  def new
  @verfication = Verfication.new
  end


  def create
    @verfication = Verfication.new(params[:verfication])
    if @verfication.save
      redirect_to profile_path(current_user.permalink), success: 'Your profile was submitted for verification. Our administration team will check and get back to you soon.'
    end

  end
end

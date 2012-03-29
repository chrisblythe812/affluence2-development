class ProfileController < ApplicationController


  before_filter :authenticate_user!, :set_profile_navigation


  def index

  end

  def edit

  end
  def update
  end

  def show

  end

end

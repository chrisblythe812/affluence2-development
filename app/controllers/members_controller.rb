class MembersController < ApplicationController

  before_filter :authenticate_user! , :set_profile_navigation

  def search

    
  end

  def latest
    @latest_members = User.members.last(18).reverse
    render :partial => 'latest'
  end
end

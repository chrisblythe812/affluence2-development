class MembersController < ApplicationController
  before_filter :authenticate_user! , :set_profile_navigation, :except => [:latest]

  def latest
    @latest_members = User.members.last(18)
    render :partial => 'latest'
  end
end

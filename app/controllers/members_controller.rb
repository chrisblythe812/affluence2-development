class MembersController < ApplicationController
  before_filter :authenticate_user! , :set_profile_navigation

         def index

         end

  def find_members

  end
  def latest_members
    @latest_members = User.members.find(:all, :order => "id desc", :limit => 5).reverse
    render :partial => 'latest_members'
  end
end

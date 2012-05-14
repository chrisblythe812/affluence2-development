class MembersController < ApplicationController

  before_filter :authenticate_user! , :set_profile_navigation

  def search
    unless params[:query].blank?
      profiles = Profile.member_search(params[:query])
    else
      profiles = Profile.all.reverse
    end

    @profile_size = profiles.size
    @profiles = Kaminari.paginate_array(profiles).page(params[:page]).per(9)

  end

  def latest
    @latest_members = User.members.last(18).reverse
    render :partial => 'latest'
  end

end

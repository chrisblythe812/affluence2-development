class MembersController < ApplicationController
  before_filter :authenticate_user! , :set_profile_navigation

  def search
    logger.info "Called Members#search ..."
    profiles = search_profile
    @profile_size = profiles.size
    @profiles = Kaminari.paginate_array(profiles).page(params[:page]).per(9)
  end

  def latest
    @latest_members = User.members.last(18).reverse
    render :partial => 'latest'
  end


  private

  def search_profile
    logger.info "Called Members#search_profile ..."
    unless params[:query].blank?
      Profile.member_search(params[:query]).reverse
    else
      Profile.all.reverse
    end
  end
end

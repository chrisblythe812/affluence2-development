class MembersController < ApplicationController
  before_filter :authenticate_user! , :set_profile_navigation

  def search
    logger.info "Called Members#search ..."
    search_profile
  end

  def latest
    @latest_members = User.active_members.last(18).reverse
    render :partial => 'latest'
  end

  def delete_connection
    if current_user.disconnect_with_user(params[:id])
      flash[:success] = "Successfully disconnected"
    else
      flash[:error] = "Not in connections or might have already disconnected"
    end
    redirect_to search_members_path
  end
  private

  def search_profile
    logger.info "Called Members#search_profile ..."
    unless params[:query].blank?
      @size = Profile.get_by_matching_name(params[:query]).size
      @profiles = Kaminari.paginate_array(Profile.get_by_matching_name(params[:query])).page(params[:page]).per(9)
    else
      @size = current_user.connections.size
      @connections_list = true
      @connections = current_user.connections.page(params[:page]).per(9)
      profiles = []
      @connections.each do |connection|
        profiles <<  connection.friend.profile
      end
      @profiles =  profiles
    end
  end
end
 
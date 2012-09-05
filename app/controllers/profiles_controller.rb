class ProfilesController < ApplicationController
  before_filter :authenticate_user!  
  autocomplete :expertise, :name, :class_name => 'ActsAsTaggableOn::Tag'
  autocomplete :interest, :name, :class_name => 'ActsAsTaggableOn::Tag'

  def autocomplete_association_name
    term = params[:term]

    if term && !term.blank?
      items =  ActsAsTaggableOn::Tag.find_by_sql("select distinct tags.* from tags " +
          "left outer join taggings on tags.id=taggings.tag_id where lower(tags.name) LIKE lower('%" +
          term + "%') and taggings.context = 'associations' order by tags.id desc limit 10")
    else
      items = {}
    end
    render :json => json_for_autocomplete(items, 'name', [])
  end
        

  ssl_required :confirm, :check_avilability, :profile_session

  before_filter :authenticate_user! , :except => [:profile_session, :confirm, :check_avilability]
  before_filter :set_profile_navigation, :except => [:settings,:confirm,:confirm_credit_card_info,:profile_billing]
  before_filter :create_braintree_object, :only =>  [:edit, :update]

  def index
    redirect_to home_index_path
  end

  def edit
    session['menu_link'] = params["value"]

    @profile = current_user.profile
    if @profile.photos.blank?
      @profile.photos.build
    elsif @profile.photos.size > 1
      @profile.photos.each do |photo|
        photo.destroy if @profile.photos.size > 1
      end
    end
    @user = @profile.user
  end 

  def update
    session['menu_link'] = params["value"]
      
    @user = resource
    @profile = resource.profile
    if params[:user].blank?
      if params[:profile][:photos_attributes]["0"][:image].nil?
        params[:profile].delete("photos_attributes")
      else
        @profile.photos.build
      end
      @profile = Profile.find(params[:id])

      respond_to do |format|
        if @profile.update_attributes(params[:profile])
          @user.save
          #          @profile.photos.first.delete
          format.html { redirect_to profile_path(@profile.user.permalink), notice: 'Profile was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render action: "edit"}
          format.json { render json: @profile.errors, status: :unprocessable_entity }
        end
      end
    elsif  params[:user]
      resource = User.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      if resource.update_with_password(params[resource_name])
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        else

        end
        sign_in resource_name, resource, :bypass => true
        respond_to do |format|
          format.html { redirect_to profile_path(@profile.user.permalink), notice: 'Profile was successfully updated.' }
          format.json { head :ok }
        end
      else
        respond_to do |format|
          @user = resource  
          resource.password = resource.password_confirmation = nil
          format.html { render action: "edit"}
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end 

  end

  def show
    @conversation = Conversation.new
    @conversation.messages.build

    user = User.find_by_permalink(params[:id])
    @profile = user.profile unless user.blank?
#    @latest_activities =  current_user != @profile.user ? @profile.user.activities_by_privacy_settings(current_user): current_user.activities.last(7).reverse
  end

  def update_notifications
    begin
      @notication_settings = current_user.profile.notification_setting
      @notication_settings.update_attributes(params["name"].to_sym => params["value"])
      render :json => {'notice' => 'updated successfully'}.to_json
    rescue   
      render :json => {'notice' => 'not updated successfully'}.to_json
    end
  end


  def create_user(user)
    user = User.new(user)
    user.save
    sign_in user
  end



  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)

    if !session[:user_info].blank? && session[:user_info][:user][:plan] == 'free'
      #create_user(session[:user_info][:user])
      @user = User.new(session[:user_info][:user])
      if @user.save
        sign_in @user
        session[:user_info] = nil
        redirect_to profile_path(current_user.permalink) and return
      else
        session[:user_info] = nil
        redirect_to new_user_registration_path and return
        #render 'registrations/new' and return
      end
    end


    if @result.success?
      if User.new(session[:user_info][:user]).valid?
        user = User.create_user_with_braintree_id(session[:user_info][:user],@result.customer.id)
        sign_in user
        session[:user_info] = nil
        redirect_to profile_path(current_user.permalink)
      else
        session[:user_info] = nil
        #todo need to populate the fields with user data.
        redirect_to new_user_registration_path
      end
    else
      #todo : render the registration new page with validations
      session[:user_info] = nil
      flash[:notice]= @result.errors._inner_inspect
      redirect_to new_user_registration_path
    end
  end


  def confirm_credit_card_info
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?
      redirect_to :action => "settings"
    else
      render :text => "settings"
    end
  end


  def user_plan
    session[:user_plan] = nil
    session[:user_plan]= params[:plan]
    respond_to do |format|
      format.json do
        render :status => 200, :json => {:plan => session[:user_plan]}
      end
    end
  end


  def profile_session
    session[:user_info] = nil
    session[:user_info]= params
    respond_to do |format|
      format.json do
        render :status => 200, :json => {:tr_data => '123213213213'}
        #render :json => {:redirect => stored_location_for(resource_name) || after_sign_in_path_for(resource)}
      end
    end
  end

  def get_paln(plan)
    return false if plan == 'free'
    return 'AFLNCE-M'if plan == 'Monthly'
    return 'AFLNCE-Y'if plan == 'Yearly'
  end

  def check_avilability
    user = User.find_all_by_email(params[:email])
    avilability = !user.blank? ? false : true
    respond_to do |format|
      format.json do
        render :status => 200, :json => {:avilability => avilability} and return
      end
    end
  end




  def billing_info_confirm

    begin
      @result = Braintree::TransparentRedirect.confirm(request.query_string)
      if @result.success?
        current_user.change_current_plan(session[:user_plan],@result.customer.id)
        flash[:success]= "You have successfully converted to #{current_user.plan} plan."
        redirect_to edit_profile_path(current_user.permalink)
      else
        @profile = current_user.profile
        @profile.photos.build if @profile.photos.blank?
        @user = @profile.user
        create_braintree_object
        session['menu_link'] = 'billing info'
        render action: :edit and return
      end
    rescue
      redirect_to edit_profile_path(current_user.permalink)
    end
  end




  def billing_info_update_confirm

    begin
      @result = Braintree::TransparentRedirect.confirm(request.query_string)
      if @result.success?
        if !session[:user_plan].blank? && (current_user.plan !=  session[:user_plan])
          current_user.change_current_plan(session[:user_plan])
        end
      else
        @profile = current_user.profile
        @profile.photos.build if @profile.photos.blank?
        @user = @profile.user
        create_braintree_object
        session['menu_link'] = 'billing info'
        render action: :edit and return
      end
      flash[:success]= "Card information was successfully updated."
      redirect_to edit_profile_path(current_user.permalink)
    rescue
      redirect_to edit_profile_path(current_user.permalink)
    end
  end


  def update_plan
    if !params[:user_plan].blank? && (current_user.plan !=  params[:user_plan])
      current_user.change_current_plan(params[:user_plan])
      flash[:success]= "Your Plan has been successfully updated to #{params[:user_plan]}."
    end
    redirect_to edit_profile_path(current_user.permalink)
  end


  def edit_privacy

  end

  def update_privacy
    begin
      @privacy_setting = current_user.profile.privacy_setting
      @privacy_setting.update_attributes(params["name"].to_sym => params["value"].to_i)
      render :json => {'notice' => params["name"] + ' setting updated successfully'}.to_json
    rescue
      render :json => {'error' => params["name"] + ' setting not updated successfully'}.to_json
    end
  end

  def set_notification_complete
    notification = NotificationTracker.find(params[:id])
    notification.update_attributes(:status => 'completed')
    render :nothing => true
  end


  def cancel_membership
    if current_user.plan != 'free'
      current_user.cancel_membership
      flash[:success] = "You have successfully converted to free member"
    end
    redirect_to edit_profile_path(current_user.permalink)
  end

  def delete_account
    if current_user.plan != 'free'
      current_user.cancel_membership
    end
    current_user.deleted
    sign_out current_user
    flash[:success] = "Your account has been deleted successfully"
    redirect_to root_path
  end
          
end

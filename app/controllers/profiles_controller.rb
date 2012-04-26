class ProfilesController < ApplicationController
  autocomplete :interest, :name, :class_name => 'ActsAsTaggableOn::Tag'
  autocomplete :expertise, :name, :class_name => 'ActsAsTaggableOn::Tag'
  autocomplete :association, :name, :class_name => 'ActsAsTaggableOn::Tag'

  ssl_required :confirm, :check_avilability, :profile_session

  before_filter :authenticate_user! , :except => [:profile_session, :confirm, :check_avilability]
  before_filter :set_profile_navigation, :except => [:settings,:confirm,:confirm_credit_card_info,:profile_billing]
  before_filter :create_braintree_object, :only =>  [:edit, :update]

  def index

  end

  def edit
    @profile = current_user.profile
    @profile.photos.build if @profile.photos.blank? 
    @user = @profile.user
  end 

  def update
    @user = resource
    @profile = resource.profile
    @profile.photos.build
    if params[:user].blank?
      @profile = Profile.find(params[:id])

      respond_to do |format|
        if @profile.update_attributes(params[:profile])
#          @profile.photos.first.delete
          format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
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
          end
          sign_in resource_name, resource, :bypass => true
          respond_to do |format|
            format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
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

  end

  def update_notifications
    begin
      p params
      @notication_settings = current_user.profile.notification_setting
      @notication_settings.update_attributes(params["name"].to_sym => params["value"])
      render :json => {'notice' => 'updated successfully'}.to_json
    rescue   
      render :json => {'notice' => 'not updated successfully'}.to_json
    end

  end

  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)

    if !session[:user_info].blank? && session[:user_info][:user][:plan] == 'free'
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
      @user = User.new(session[:user_info][:user])
      if @user.save
        @user.braintree_customer_id = @result.customer.id
        @user.save
        SubscriptionFeeTracker.create(:user_id => @user.id,:renewal_date => Date.today, :amount => @user.plan_amount )
        #@user.with_braintree_data!
        #@credit_card = @user.default_credit_card
        #subscription_result = Braintree::Subscription.create(
        #:payment_method_token => @credit_card.token,
        #:plan_id => 'AFLNCE-M'
        #)

        #if subscription_result.success?
        #puts subscription_result.subscription.id
        # puts subscription_result.subscription.transactions[0].id
        #render :text => "subscription_result.subscription.id-----#{subscription_result.subscription.id}---subscription_result.subscription.transactions[0].id-----#{subscription_result.subscription.transactions[0].id}" and return
        #else
        #puts subscription_result.transaction.status
        #render :text => "subscription_result.transaction.status---#{subscription_result.transaction.status}" and return
        #end





        sign_in @user
        session[:user_info] = nil
        #todo : set the user as logged in
        #todo : do the subscription
        redirect_to profile_path(current_user.permalink) #and return
      else
        customer_delete_result = Braintree::Customer.delete(@result.customer.id)
        #if customer_delete_result.success?
        #render :text=> "vault was deleted successfully"  and return
        #else
        #render :text=> "unable to delete vault" and return
        #end
        #todo : render the registration new page with validations and delete the vault in braintree
        session[:user_info] = nil
        redirect_to new_user_registration_path
      end

    else
      @user = User.new(session[:user_info][:user])
      #if @user.valid?
      #todo : render the registration new page with validations
      #else
      #todo : render the registration new page with validations
      #end
      session[:user_info] = nil
      flash[:notice]= @result.errors._inner_inspect
      redirect_to new_user_registration_path
      #render :text => @result.errors._inner_inspect and return

      #@tr_data = Braintree::TransparentRedirect.
      #create_customer_data(:redirect_url => confirm_profile_url)
      #render :action => "settings"
    end
  end


  def confirm_credit_card_info
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?
      redirect_to :action => "settings"
    else
      #@credit_card = Braintree::CreditCard.find(@result.params[:payment_method_token])
      #@tr_data = Braintree::TransparentRedirect.
      #update_credit_card_data(:redirect_url => confirm_credit_card_info_profile_url,
      #:payment_method_token => @credit_card.token)
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
       change_current_plan(session[:user_plan],@result.customer.id)
       flash[:success]= "You have successfully converted to #{current_user.plan} plan."
      redirect_to edit_profile_path(current_user.permalink)
    else
      @profile = current_user.profile
      @profile.photos.build if @profile.photos.blank?
      @user = @profile.user
      create_braintree_object
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
      change_current_plan(session[:user_plan])
    else
      @profile = current_user.profile
      @profile.photos.build if @profile.photos.blank?
      @user = @profile.user
      create_braintree_object
      render action: :edit and return
    end
    flash[:success]= "Card information was successfully updated."
    redirect_to edit_profile_path(current_user.permalink)
    rescue
      redirect_to edit_profile_path(current_user.permalink)
    end
  end


  def update_plan
    if !params[:user_plan].blank?
      change_current_plan(params[:user_plan])
      #flash[:notice]= "Your Plan has been successfully updated to #{params[:user_plan]}."
      redirect_to edit_profile_path(current_user.permalink)
    end
  end


  def change_current_plan(new_plan,braintree_customer_id=nil)
    if !new_plan.blank? && (current_user.plan !=  new_plan)
      current_user.plan = new_plan
      current_user.braintree_customer_id = braintree_customer_id if !braintree_customer_id.blank?
      current_user.save
      session[:user_plan]=nil
      update_subscription(current_user)
      flash[:success]= "Your Plan has successfully changed to #{params[:user_plan]}."
    end
  end


  def update_subscription(current_user)
    user_subscription = SubscriptionFeeTracker.where(:user_id => current_user.id).not_completed.last
    if !user_subscription.blank?
      user_subscription.update_attributes(:amount => current_user.plan_amount)
    else
      SubscriptionFeeTracker.schedule(current_user)
    end
  end

  def edit_privacy

  end

  def update_privacy
    begin
      p params
      @privacy_setting = current_user.profile.privacy_setting
      @privacy_setting.update_attributes(params["name"].to_sym => params["value"].to_i)
      render :json => {'notice' => params["name"] + ' setting updated successfully'}.to_json
    rescue
      render :json => {'error' => params["name"] + ' setting not updated successfully'}.to_json
    end
  end
          
end

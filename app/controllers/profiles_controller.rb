class ProfilesController < ApplicationController
  autocomplete :interest, :name, :class_name => 'ActsAsTaggableOn::Tag'
  autocomplete :expertise, :name, :class_name => 'ActsAsTaggableOn::Tag'
  autocomplete :association, :name, :class_name => 'ActsAsTaggableOn::Tag'

  ssl_required :confirm, :check_avilability, :profile_session

   before_filter :authenticate_user! , :except => [:profile_session, :confirm, :check_avilability]
   before_filter :set_profile_navigation, :except => [:settings,:confirm,:confirm_credit_card_info,:profile_billing]

  def index

  end

  def edit

  end
  def update
  end

  def show

  end

  def settings

  
  end

  def confirm
    @result = Braintree::TransparentRedirect.confirm(request.query_string)

    if !session[:user_info].blank? && session[:user_info][:user][:plan] == 'free'
      @user = User.new(session[:user_info][:user])
      if @user.save!
        sign_in @user
        session[:user_info] = nil
        redirect_to :action => "settings" and return
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
          redirect_to :action => "settings" #and return
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

end

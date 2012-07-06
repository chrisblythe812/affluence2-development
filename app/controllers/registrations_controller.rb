class RegistrationsController < Devise::RegistrationsController
  layout "welcome"
  skip_before_filter :verify_authenticity_token
  include DeviseJsonAdapter
  ssl_required :new

  def new
    @tr_data = Braintree::TransparentRedirect.
        create_customer_data(:redirect_url => confirm_profiles_url())
    super
  end

  def create
    super
  end

  def update
    super
  end


end
  

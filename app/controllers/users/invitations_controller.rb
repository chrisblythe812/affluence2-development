class Users::InvitationsController < Devise::InvitationsController
  protect_from_forgery :except => [:contacts_provider_callback]
  # we can overide methods here
  # original controller for reference https://raw.github.com/scambra/devise_invitable/master/app/controllers/devise/invitations_controller.rb
  #  prepend_before_filter :require_no_authentication
  layout 'invitation', :only => [:edit, :update] 
  # GET /resource/invitation/new
  def new
    #    if $rollout.active?(:contact_invitations, current_user)
    #      setup_email_services(:all)
    #    end
    build_resource
    resource.build_profile
    current_user.invitations.where(:status => 1).each do |invite_history|
      invite_history.update_attributes(:status => 0) if (Time.now - invite_history.created_at) > User.invite_for.to_i
    end
    @invited_users = current_user.invitations.order("created_at DESC")
    render :new
  end

  def get_contacts
    redirect_to(params[:provider])
  end

  def import_contacts
    if params[:users] && !params[:users].empty?
      unless Rails.env.development?
        params[:users].keep_if{|email| email.match(/^.+@.+$/)}.each do |invite_email|
          unless User.exists?(:email => invite_email)
            if self.resource = resource_class.invite!({:email => invite_email , :status => "invited"}, current_inviter)
              profile = Profile.find_or_create_by_user_id(resource.id, {:country => 'US'})
            end
          end
        end
      end
      flash[:notice] = "Invitations sent."
    end
    redirect_to new_user_invitation_path
  end

  def contacts_provider_callback
    @page ||= params[:page].present? ? params[:page] : 1
    if current_user.has_imported_contacts?(params[:provider])
      @contacts = Kaminari.paginate_array(current_user.fetch_imported_contacts_from_redis(params[:provider])).page(params[:page]).per(16)
      respond_to do |format|
        format.html{render :imported_contacts, :layout => "settings"}
        format.js{ render "imported_contacts.js"}
      end
    else
      if consumer = Contacts.deserialize_consumer(params[:provider].to_sym, session["#{params[:provider]}_consumer"])
        if consumer.authorize(params)
          begin
            current_user.save_imported_contacts_to_redis(params[:provider],consumer.contacts)
            @contacts = Kaminari.paginate_array(current_user.fetch_imported_contacts_from_redis(params[:provider])).page(params[:page]).per(16)
            render :imported_contacts, :layout => "settings"
          rescue NoMethodError
            redirect_to new_user_invitation_path, :notice => "No contacts were available to import from #{params[:provider].camelcase}."
          end
        else
          redirect_to new_user_invitation_path,:notice => "There was an error connecting with that service."
        end
      end
    end
  end


  # POST /resource/invitation
  def create
    user = User.where(:email => params[:user][:email]).first

    if user.present?
      if user.invited_by.present?
        if user.invitation_accepted_at.nil?
          if user.invitation_expired?
            send_invitation
          else
            flash[:error] = "Some one already invited #{user.email}."
          end
        else
           flash[:error] = "#{user.email} is already registered."
        end
      end
    else
      send_invitation
    end

    redirect_to new_user_invitation_path
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    if params[:invitation_token] && self.resource = resource_class.to_adapter.find_first( :invitation_token => params[:invitation_token] )
      render :edit
    else
      set_flash_message(:alert, :invitation_token_invalid)
      redirect_to after_sign_out_path_for(resource_name)
    end
  end

  #   PUT /resource/invitation
  def update
    self.resource = resource_class.accept_invitation!(params[resource_name])
    resource.status
  
    if resource.errors.empty?
      update_invitation_history_of_invited_to(2)
      set_flash_message :notice, :updated
      sign_in(resource_name, resource)
      respond_with resource, :location => after_accept_path_for(resource)
    else
      update_invitation_history_of_invited_to(0)
      respond_with_navigational(resource){ render :edit }
    end
  end


  private

  def setup_email_services(provider)
    url = Rails.env.production? ? "http://www.affluence.org/users/contacts/callback" : contacts_provider_callback_url
    case provider
    when :google
      google_contacts = Contacts::Google.new
      @google_oauth_url = google_contacts.authentication_url("#{url}?provider=google")
      session[:google_consumer] = google_contacts.serialize
    when :yahoo
      yahoo_contacts = Contacts::Yahoo.new
      @yahoo_oauth_url = yahoo_contacts.authentication_url("#{url}?provider=yahoo")
      session[:yahoo_consumer] = yahoo_contacts.serialize
    when :windows_live
      windows_live_contacts = Contacts::WindowsLive.new
      @windows_live_oauth_url = windows_live_contacts.authentication_url("#{url}?provider=windows_live")
      session[:windows_live_consumer] = windows_live_contacts.serialize
    when :all
      setup_email_services(:google)
      setup_email_services(:yahoo)
      setup_email_services(:windows_live)
    end
  end

  def update_invitation_history_of_invited_to(status = 0)
    invitation_history = InvitationHistory.find_by_user_id(self.resource.invited_by_id)
    invitation_history.update_attributes(:status => status)
  end

  private

  def send_invitation
    self.resource = resource_class.invite!(params[:user].merge({"status" => "active", :plan => "free"}), current_inviter)
    flash[:success] = "Your invite has sucessfully been sent to #{self.resource.email}."
    self.resource.build_profile(:first_name => "first name", :last_name => "last name", :city => "city", :country => "US")
    current_user.invitations.build(:email => self.resource.email, :status => 1)
    current_user.save!
    self.resource.save!
  end
end
class Users::InvitationsController < Devise::InvitationsController
  protect_from_forgery :except => [:contacts_provider_callback]
  # we can overide methods here
  # original controller for reference https://raw.github.com/scambra/devise_invitable/master/app/controllers/devise/invitations_controller.rb
  #  prepend_before_filter :require_no_authentication
  layout 'invitation', :only => [:edit, :update] 
  # GET /resource/invitation/new
  def new
    session[:consumer] = {}
    build_resource
    resource.build_profile
    current_user.invitations.where(:status => 1).each do |invite_history|
      invite_history.update_attributes(:status => 0) if (Time.now - invite_history.created_at) > User.invite_for.to_i
    end
    @invited_users = current_user.invitations.order("created_at DESC")
    render :new
  end

  def get_contacts
    if params[:provider]
      case params[:provider]
      when "google"
        consumer = Contacts::Google.new
      when "yahoo"
        consumer = Contacts::Yahoo.new
      when "msn"
        consumer = Contacts::WindowsLive.new
      end
      return_url = "#{contacts_provider_callback_url}?provider=#{params[:provider]}"
      oauth_url = consumer.authentication_url(return_url)
      session[:consumer][params[:provider]] = consumer.serialize

      redirect_to(oauth_url)
    else
      flash[:error] = "Please select a provider to import contacts."
      redirect_to new_user_invitation_path
    end
  end

  def import_contacts
    sent_email_to = []
    skipped_emails = []
    if params[:users] && !params[:users].empty?
      params[:users].keep_if{|email| email.match(/^.+@.+$/)}.each do |invite_email|
        user = User.where(:email => invite_email).first
        if (user.nil?) || (user.present? && user.can_receive_invitation?)
          send_invitation(invite_email)
          sent_email_to << invite_email
        else
          skipped_emails << invite_email
        end
      end
    end
    flash[:success] = "Invitations sent to #{sent_email_to.join(', ')}" unless sent_email_to.blank?
    flash[:error] = "Could not sent mail to #{skipped_emails.join(', ')}" unless skipped_emails.blank?
    redirect_to new_user_invitation_path
  end

  def contacts_provider_callback
    logger.info '111111111111111111111111111111111111'
    if current_user.has_imported_contacts?(params[:provider])
      logger.info '2222222222222222222222222222'
      @contacts = Kaminari.paginate_array(current_user.contacts.find_by_provider(params[:provider]).emails_list.split(', ')).page(params[:page]).per(20)

      respond_to do |format|
        format.html{render :imported_contacts}
      end
    else
      logger.info '3333333333333333333333333333'
      consumer = Contacts.deserialize_consumer(params[:provider].to_sym, session[:consumer][params[:provider]])
      if consumer.authorize(params)
        begin
          logger.info '4444444444444444444444'
          logger.info consumer.contacts
          contacts = []
          consumer.contacts.each do |contact|
            contact.emails.each do |email|
              contacts << email
            end
          end
          logger.info '55555555555555555555'
          logger.info contacts

          contact = Contact.new 
          contact.user_id = current_user.id
          contact.provider = params[:provider]
          contact.emails_list = contacts.join(', ')
 
          if contact.save!
            @contacts = current_user.contacts.find_by_provider(params[:provider]).emails_list.split(', ')
            @contacts = Kaminari.paginate_array(@contacts).page(params[:page]).per(20)
          else
            redirect_to new_user_invitation_path, :notice => "Could not save contacts from #{params[:provider].camelcase}."
          end

          render :imported_contacts  
        rescue NoMethodError
          redirect_to new_user_invitation_path, :notice => "No contacts were available to import from #{params[:provider].camelcase}."
        end
      else
        redirect_to new_user_invitation_path,:notice => "There was an error connecting with that service."
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
            send_invitation(params[:user][:email])
            flash[:success] = "Your invite has sucessfully been sent to #{self.resource.email}."
          else
            flash[:error] = "Some one already invited #{user.email}."
          end
        else
          flash[:error] = "#{user.email} is already registered."
        end
      else
        flash[:error] = "#{user.email} is already registered."
      end
    else
      send_invitation(params[:user][:email])
      flash[:success] = "Your invite has sucessfully been sent to #{self.resource.email}."
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

  def update_invitation_history_of_invited_to(status = 0)
    invitation_history = InvitationHistory.find_by_user_id(self.resource.invited_by_id)
    invitation_history.update_attributes(:status => status)
  end

  def send_invitation(email)
    self.resource = resource_class.invite!({:email => email}.merge({"status" => "active", :plan => "free"}), current_inviter)
    self.resource.build_profile(:first_name => "first name", :last_name => "last name", :city => "city", :country => "US")
    current_user.invitations.build(:email => self.resource.email, :status => 1)
    current_user.save!
    self.resource.save!
  end
end  
class Users::InvitationsController < Devise::InvitationsController
  protect_from_forgery :except => [:contacts_provider_callback]
  # we can overide methods here
  # original controller for reference https://raw.github.com/scambra/devise_invitable/master/app/controllers/devise/invitations_controller.rb
  #  prepend_before_filter :require_no_authentication
  layout 'invitation', :only => [:edit, :update]
  # GET /resource/invitation/new
  def new
    session[:consumer] = {}
    session[:imported_from] = [] if session[:imported_from].nil?
    session[:select_all] = false
    session[:selected_emails] = {"1" => []}
    session[:unselected_emails] = {"1" => []}
    session[:state] = "0"
 
    build_resource
    resource.build_profile
    current_user.invitations.where(:status => 1).each do |invite_history|
      invite_history.update_attributes(:status => 0) if (Time.now - invite_history.created_at) > User.invite_for.to_i
    end
    @invited_users = current_user.invitations.order("created_at DESC")

    if session[:temp]
      params[:temp] = session[:temp]
      session[:temp] = nil
    end

    render :new
  end
  
  def get_contacts
    if params[:provider]

      contact = current_user.contacts.find_by_provider(params[:provider])
      contact.delete if contact.present?

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

    if params[:state_changed] == "true"
      session[:select_all] = false
      session[:selected_emails] = {"1" => []}
      session[:unselected_emails] = {"1" => []}
    end

    user_indexes = []
    session[:state] = params[:current_state]
    users = current_user.contacts.find_by_provider(session[:provider]).emails_list.split(', ')

    if session[:state] == "1"
    elsif session[:state] == "0"
      session[:selected_emails][params[:current_page]] = params[:users]  
      session[:selected_emails].each_value do |value|
        user_indexes = user_indexes + value
      end

      temp = []
      user_indexes.each do |index|
        temp << users[index.to_i]
      end
      users = temp 
    elsif session[:state] == "2"

      session[:unselected_emails][params[:current_page]] = params[:unchecked_emails].split(',')
      session[:unselected_emails].each_value do |value|
        user_indexes = user_indexes + value
      end
      user_indexes.uniq!

      user_indexes.sort_by(&:to_i).reverse.each do |index|
        users.delete_at(index.to_i)
      end  
    end
    check_emails_and_send_invitation users
  end

  def contacts_provider_callback

    if current_user.has_imported_contacts?(params[:provider]) && session[:imported_from].include?(params[:provider])
      @contacts = Kaminari.paginate_array(current_user.contacts.find_by_provider(params[:provider]).emails_list.split(', ')).page(params[:page]).per(20)

      session[:provider] = params[:provider]
      session[:prev_page] = params[:prev_page] unless params[:prev_page].nil?

      if params[:state_changed] == "true"
        session[:select_all] = false
        session[:selected_emails] = {"1" => []}
        session[:unselected_emails] = {"1" => []}
      end
      session[:selected_emails][params[:page]] = [] unless session[:selected_emails].has_key?(params[:page])
      session[:unselected_emails][params[:page]] = [] unless session[:unselected_emails].has_key?(params[:page])
      session[:state] = params[:state] unless params[:state].nil?
  
      case params[:state]
      when "0"
        session[:selected_emails][params[:prev_page]] = params[:selected_emails].split(',')
      when "1"
        session[:select_all] = params[:select_all]
        session[:selected_emails][params[:page]] = [] unless session[:selected_emails].has_key?(params[:page])
      when "2"
        session[:unselected_emails][params[:prev_page]] = params[:unselected_emails].split(',')
        session[:unselected_emails][params[:page]] = [] unless session[:unselected_emails].has_key?(params[:page])
      end

      respond_to do |format|
        format.html{render :imported_contacts}
      end
    else
      consumer = Contacts.deserialize_consumer(params[:provider].to_sym, session[:consumer][params[:provider]])
      if consumer.authorize(params)
        begin
          contacts = []
          consumer.contacts.each do |contact|
            contact.emails.each do |email|
              contacts << email
            end
          end
          emails = []

          User.select(:email).registered_users.each do |user|
            emails << user.email
          end

          contacts = contacts - emails

          contact = current_user.contacts.find_or_initialize_by_provider_and_user_id(params[:provider], current_user.id)

          if contact.update_attributes(:emails_list => contacts.sort.join(', '))
            @contacts = Kaminari.paginate_array(contact.emails_list.split(', ')).page(params[:page]).per(20)
            session[:imported_from] << params[:provider]
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
    if params[:user][:emails].present?
      user_emails = params[:user][:emails].split(',')
      check_emails_and_send_invitation user_emails, params[:user][:invitation_email_body]
    else
      session[:temp] = true
      flash[:error] = "Enter email."
      redirect_to new_user_invitation_path
    end
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
      redirect_to edit_profile_path(resource.permalink)
      #respond_with resource, :location => after_accept_path_for(resource)
    else
      update_invitation_history_of_invited_to(0)
      respond_with_navigational(resource){ render :edit }
    end
  end


  private

  def update_invitation_history_of_invited_to(status = 0)
    invitation_history = InvitationHistory.where(:email=>self.resource.email, :user_id=>self.resource.invited_by_id, :status=>1).last
    invitation_history.update_attributes(:status => status) unless invitation_history.nil?
  end

  def send_invitation(email, body)
    begin
      self.resource = resource_class.invite!({:email => email}.merge({"status" => "active", :plan => "free", :invitation_email_body => body}), current_inviter)
      current_user.invitations.build(:email => self.resource.email, :status => 1)
      current_user.save! if self.resource.save!
    rescue Exception => e
      resource_class.find_by_email(email).delete
      raise e
    end
  end

  def check_emails_and_send_invitation(emails, body = nil)
    begin
      sent_email_to = []
      skipped_emails = []
      if emails && !emails.empty?
        emails.keep_if{|email| email.match(/^.+@.+$/)}.each do |invite_email|
          user = User.where(:email => invite_email.strip).first

          if (user.nil?) || (user.present? && user.can_receive_invitation?)
            send_invitation(invite_email, body)
            sent_email_to << invite_email
          else
            skipped_emails << invite_email
          end
        end
      end
      flash[:success] = "Your invite has sucessfully been sent to #{sent_email_to.join(', ')}." unless sent_email_to.blank?
      flash[:error] = "#{skipped_emails.join(', ')} is already registered or invited." unless skipped_emails.blank?
    rescue Exception => e
      flash[:error] = e.inspect
    end
    redirect_to new_user_invitation_path
  end
end

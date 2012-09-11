ActiveAdmin.register User do
  actions :all, :except => [:new, :destroy]

  #actions :index, :show, :new, :create, :update, :edit


  filter :email


  scope :active_members, :default => true
  scope :suspended_members
  scope :deleted_members

  #config.clear_sidebar_sections!


  index do
    column("Name") do |user|
      auto_link(user)
    end
    column("Email", :email)
    #column("Member ID", :id)
    column("Location") {|user| user.profile.city+", "+user.profile.country}
    column("Status", :status) do |user|
       user.account_active? ? icon(:check) : icon(:x)
    end
    column("Membership plan", :plan)
    column("Invitation Points", :points)
    column('Actions',:sortable => false) do |event|
      link_to 'details', admin_user_path(event)
    end
  end


  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Edit User Details" do
      f.input :email , :label => "Email"
      f.input :status,:as => :select, :collection => [['Active', 'active'], ['Suspended', 'suspended']] , :include_blank => false
     end

    f.inputs :name => "Profile", :for => :profile do |profile_form|
      profile_form.input :first_name
      profile_form.input :last_name
      profile_form.input :city
      profile_form.input :state
      #profile_form.input :country, :as => :country
      profile_form.input :phone
      profile_form.input :bio
      profile_form.input :title
      profile_form.input :company

    end

    #f.inputs :name => "Notification Settings", :for => :notification_settings do |notification_settings_form|
      #notification_settings_form.input :newsletter
      #notification_settings_form.input :offers
      #notification_settings_form.input :events
      #notification_settings_form.input :messages
      #notification_settings_form.input :event_reminders
      #notification_settings_form.input :site_news
    #end


    f.buttons
  end


  action_item :only => [:show] do
    if user.account_active?
    link_to('Suspend', suspend_admin_user_path(user.id))
    elsif user.account_suspended?
      link_to('Active', unsuspend_admin_user_path(user.id))
    end
  end

  member_action :suspend, :method => :get do
    user = User.find(params[:id])
    user.suspended
    flash[:notice] = "Member has been suspended"
    redirect_to :action => :show
  end

  member_action :unsuspend, :method => :get do
    user = User.find(params[:id])
    user.unsuspended
    flash[:notice] = "Member has been unsuspended"
    redirect_to :action => :show
  end



  member_action :update,  :method => :post do
    @user = User.find(params[:id]) unless params[:id].blank?
    if @user.update_attributes(params[:user])
      redirect_to :action => :show, :id => @user.id
    else
      render :edit
    end
  end


  member_action :destroy,  :method => :post do
    @user = User.find(params[:id]) unless params[:id].blank?
    if @user.plan != 'free'
      @user.cancel_membership
    end

    if @user.status == 'suspended'
    @user.unsuspended
    end


    @user.deleted
    flash[:notice] = "Member was successfully deleted"
    redirect_to :action => :index
  end


  show :title => "User details" do | user |
    panel "Profile Info" do
    attributes_table_for user do
      row("Name") {|user| user.name}
      row :email
      row("Unique ID(permalink)") {|user| user.permalink}
      #row("Member ID") {|user| user.id}
      row("Payment type") {|user| user.plan}
      row("Location") {|user| user.profile.city+", "+user.profile.country}
      row("Phone Number") {|user| user.profile.phone}
      row("Bio") {|user| user.profile.bio}
      row("Company") {|user| user.profile.company}
      row("Invitation Source")  {|user| user.profile.invitation_source}
      row("Account created on") {|user| global_date_format(user.created_at)}
      row("Last logged on") {|user| global_date_format(user.last_sign_in_at)}
      row("Associations") {|user| user.profile.association_list }
      row("Interests") {|user| user.profile.interest_list}
      row("Expertise") {|user| user.profile.expertise_list}
    end
    end

    panel "Email Notifications"  do
      attributes_table_for user do
        row("News Letter") { |user| user_email_notifications(user.profile.notification_setting.newsletter) }
        row("New Events") { |user| user_email_notifications(user.profile.notification_setting.events) }
        row("New Offers") { |user| user_email_notifications(user.profile.notification_setting.offers) }
        row("New Messages") { |user| user_email_notifications(user.profile.notification_setting.messages) }
        row("Event Reminders") { |user| user_email_notifications(user.profile.notification_setting.event_reminders) }
        row("Site News") { |user| user_email_notifications(user.profile.notification_setting.site_news) }
      end
    end

    if user.promotions.count > 0
    panel "Orders History"  do
      table_for user.promotions do |promotion |
        column("Promotion ID") { |promotion| promotion.promotionable.id }
        column("Promotion Type") { |promotion| promotion.promotionable_type }
        column("Promotion") { |promotion| promotion.promotionable.title }
        #column("Cost") { |order| "$#{order.amount}" }
      end
    end
    else
      panel "Orders History" do
        "No Orders"
      end
    end



  end
end


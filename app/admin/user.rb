ActiveAdmin.register User do
  actions :all, :except => [:new]
  filter :email
  filter :plan
  filter :name
  #filter lambda{ User.profile.first_name }

   scope :all_members, :default => true
   scope :active_members
   scope :suspended_members

  config.clear_sidebar_sections!


  index do
    column("Name") {|user| user.name}
    column("Email", :email)
    #column("Member ID", :id)
    column("Location") {|user| user.profile.city+", "+user.profile.country}
    column("Status", :status){|user| user.status}
    column("Membership plan", :plan)
    column('Actions',:sortable => false) do |event|
      link_to 'details', admin_user_path(event)
    end
  end


  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Create New User" do
      f.input :email , :label => "Email"
      f.input :role , :label => "Role"
    end

    f.inputs :name => "Profile", :for => :profile do |profile_form|
      profile_form.input :first_name
      profile_form.input :last_name
    end

    f.inputs :name => "Notification Settings", :for => :notification_settings do |notification_settings_form|
      notification_settings_form.input :newsletter
      notification_settings_form.input :offers
      notification_settings_form.input :events
      notification_settings_form.input :messages
      notification_settings_form.input :event_reminders
      notification_settings_form.input :site_news
    end


    f.buttons
  end


  member_action :update,  :method => :post do
    @user = User.find(params[:id]) unless params[:id].blank?
    if @user.update_attributes(params[:user])
      redirect_to :action => :show, :id => @user.id
    else
      render :edit
    end
  end


  show :title => "User details" do | user |
    attributes_table_for user do
      row("Name") {|user| user.profile.first_name}
      row :email
      row("Member ID") {|user| user.id}
      row("Satus") {|user| user.plan}
      row("Location") {|user| user.profile.city+", "+user.profile.country}
      row("Phone Number") {|user| user.profile.phone}
      row("Bio") {|user| user.profile.bio}
      row("Company") {|user| user.profile.company}
      row("Associations") {|user| user.profile.associations }
      row("Interests") {|user| user.profile.interests}
      row("Expertise") {|user| user.profile.expertises}

      row("News Letter") { |user| user.profile.notification_setting.newsletter }
      row("New Events") { |user| user.profile.notification_setting.events }
      row("New Offers") { |user| user.profile.notification_setting.offers }
      row("New Messages") { |user| user.profile.notification_setting.messages }
      row("Event Reminders") { |user| user.profile.notification_setting.event_reminders }
      row("Site News") { |user| user.profile.notification_setting.site_news }
    end

    section "Orders for this user" do
      table_for user.payments do |order|
        column("Order ID") { |order| order.id }
        column("Date") { |order| order.created_at }
        column("Cost") { |order| order.amount }
      end
    end
  end
end

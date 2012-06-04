ActiveAdmin.register User do
  actions :all, :except => [:new]
  filter :email
  filter :plan
  filter :name
  #filter lambda{ User.profile.first_name }

   #scope :all_members, :default => true
   scope :active_members, :default => true
   scope :suspended_members

  config.clear_sidebar_sections!


  index do
    column("Name") do |user|
      auto_link(user)
    end
    column("Email", :email)
    #column("Member ID", :id)
    column("Location") {|user| user.profile.city+", "+user.profile.country}
    column("Status", :status) do |user|
       user.status? ? icon(:check) : icon(:x)
    end
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
    panel "Profile Info" do
    attributes_table_for user do
      row("Name") {|user| user.profile.first_name}
      row :email
      #row("Member ID") {|user| user.id}
      row("Payment type") {|user| user.plan}
      row("Location") {|user| user.profile.city+", "+user.profile.country}
      row("Phone Number") {|user| user.profile.phone}
      row("Bio") {|user| user.profile.bio}
      row("Company") {|user| user.profile.company}
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

    if user.payments.count > 0
    panel "Orders History"  do
      table_for user.payments do |order|
        column("Order ID") { |order| order.id }
        column("Date") { |order| order.created_at }
        column("Cost") { |order| order.amount }
      end
    end
    else
      panel "Orders History" do
        "No Orders"
      end
    end



  end
end

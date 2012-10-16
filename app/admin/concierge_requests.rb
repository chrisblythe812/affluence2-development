ActiveAdmin.register ConciergeRequest, :namespace=> :admin do

  menu :label => "Concierge Requests"

  actions :all

  #config.sort_order = 'user_id_desc'



  #scope :concierge, :default => true



  config.clear_sidebar_sections!

  controller do
    autocomplete :user, :id
  end

  member_action :create, :method => :post do
    ConciergeRequest.transaction do
      @concierge_request = ConciergeRequest.new(params[:concierge_request])
      @concierge_request.operator_id = current_user.id
      if @concierge_request.save
        redirect_to :action => :show, :id => @concierge_request.id
      else
        flash[:notice] = "Unable to create concierge request"
        render :new
      end
    end
  end


  form  :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "New Concierge Request form" do
      #f.input :user_id #:as => :autocomplete, :url => autocomplete_user_id_admin_concierge_requests_path
      #f.input :user_id, :as => :select, :include_blank => false
      f.input :user_id, :as => :select,:collection => User.concierge_users
      #f.input :operator_id, :value => 1, :hidden => true
      f.input :request_note , :label => "Request"
      f.input :completion_date, :label => "Date the Request has to be complete by"
      f.input :todo, :label => "Description"
    end
    f.buttons
  end

  show :title => "Concierge Request" do | concierge_request |
    panel "Requested Info" do
      attributes_table_for concierge_request do
        row("User") {|concierge_request| concierge_request.user.name}
        row("Email") {|concierge_request| concierge_request.user.email}
        row("Request Note") {|concierge_request| concierge_request.request_note}
        row("Description") {|concierge_request| concierge_request.todo}
        row("Date the Request is made") {|concierge_request| global_date_format(concierge_request.created_at)}
        #row("Date the Request has to be complete by") {|concierge_request| concierge_request.completed_date }
      end
    end

    panel "Conversation with User" do
      table_for concierge_request.interactions do |interaction|
         column("Message") { |interaction| "#{interaction.interactable.sender.name} : #{interaction.interactable.body}" }
      end


    end


   end























  #action_item :only => [:show] do
    #link_to('Send Message', message_admin_concierge_request_path(concierge_request.id))
  #end

  #member_action :message, :method => :get do
   # @concierge_request = ConciergeRequest.find(params[:id])

  #end
  #index :download_links => false  do
    #column(:Member, :sortable => false){|promotions_user| promotions_user.user.name}
    #column(:Profile, :sortable => false){|promotions_user| image_tag display_image(promotions_user.user.profile.photos, :thumb)}
    #column('Total calls', :sortable => false) { |promotion_user| promotion_user.user.concierge_calls_count }
    #column(:created_at, :sortable => false) { |concierge| global_date_format(concierge.created_at) }
    #column('Actions', :sortable => false) do |promotions_user|
     # link_to 'View call history', view_call_info_admin_concierge_path(promotions_user.user)
    #end
  #end

  #member_action :autocomplete_user_id,:method => :get do
  #@user = User.find(params[:id])
  #@calls = @user.concierge_calls
  #end

  #show do |user|
    #section "Calls made by the member" do
     #table_for @promotions_user do |concierge_call|
        #column("Name") { |promotions_user| promotions_user.user.profile.first_name }
        #column("profile") { |promotions_user| display_image(promotions_user.user.profile.photos, :thumb) }
      #end
    #end
  #end



end

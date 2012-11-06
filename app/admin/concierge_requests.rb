ActiveAdmin.register ConciergeRequest do
  
  controller do
    skip_before_filter :is_admin?
  end

  config.sort_order = 'updated_at desc'
  
  menu :label => "Concierge Requests"

  actions :all, :except => [:destroy]
  
  filter :user ,:as => :select , :collection =>  proc { ConciergeRequest.active_users }
  filter :code, :as => "string", :label => "CR ID"
  filter :title, :as => "string"
  filter :request_note, :as => "string"
  filter :created_at
  filter :completion_date
  filter :workflow_state, :as => :select , :collection =>  proc { ConciergeRequest.all_status }
     
  scope :all, :default => true do |concierge_requests|
    concierge_requests.join_user_profile
  end
  scope :completed , :if => proc { current_user.superadmin? } do |concierge_requests|
    concierge_requests.completed.join_user_profile
  end
  scope :rejected , :if => proc { current_user.superadmin? } do |concierge_requests|
    concierge_requests.rejected.join_user_profile
  end
  scope :my do |concierge_requests|
    concierge_requests.my_requests(current_user.id).join_user_profile
  end
  scope "My (Completed)" do |concierge_requests|
    concierge_requests.completed(current_user.id).join_user_profile
  end
  scope "My (Rejected)" do |concierge_requests|
    concierge_requests.rejected(current_user.id).join_user_profile
  end


  #config.sort_order = 'user_id_desc'

  #scope :concierge, :default => true


  index :download_links => false  do
    column(:Member, :sortable => "profiles.first_name"){|concierge_request| concierge_request.user.name}
    column(:Profile){|concierge_request| image_tag display_image(concierge_request.user.profile.photos, :thumb)}
    column(:title){|concierge_request| concierge_request.title}
    column(:request_note){|concierge_request| concierge_request.request_note}
    column(:created_at, :sortable => :created_at){|concierge_request|  global_date_format(concierge_request.created_at)}
    column(:updated_at, :sortable => :updated_at){|concierge_request|  global_date_format(concierge_request.updated_at)}
    column(:completion_date, :sortable => :completion_date){|concierge_request|  global_date_format(concierge_request.completion_date)}
    column(:workflow_state, :sortable => :workflow_state){|concierge_request|  concierge_request.workflow_state}
    column('Actions', :sortable => false) do |concierge_request|
      link_to('Interactions', admin_concierge_request_path(concierge_request)) + " " + \
      link_to('Edit', edit_admin_concierge_request_path(concierge_request)) + " " + \
      # link_to('View User', admin_concierge_request_path(concierge_request) , :method => :delete , :confirm => "Are you sure you want to delete this?")
   end
  end
 

  #member_action :show, :method => :get do
    #@concierge_request = ConciergeRequest.find(params[:id])
    #@message = Message.new
  #end

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
  
  # collection_action :index
 controller do
   def new
     @user = User.find(params[:user_id]) if params[:user_id]
     @concierge_request = ConciergeRequest.new
     @concierge_request.user_id = @user.id if @user
     @concierge_request.completion_date = Date.today if @concierge_request.new_record?
   end
 end

  member_action :edit do
    @concierge_request = ConciergeRequest.find(params[:id])
  end

  form  :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "New Concierge Request form" do
    #f.input :user_id #:as => :autocomplete, :url => autocomplete_user_id_admin_concierge_requests_path
    #f.input :user_id, :as => :select, :include_blank => false
      if f.object.user_id
        f.input :user_id, :as => :select,:collection => User.concierge_users, :selected => f.object.user_id, :input_html => {:disabled => true}
        f.input :user_id, :as => :hidden
      else
        f.input :user_id, :as => :select,:collection => User.concierge_users
      end

      #f.input :operator_id, :value => 1, :hidden => true
      f.input :title, :input_html => {:readonly => f.object.new_record? ? false : true}
      f.input :request_note , :label => "Request", :input_html => {:readonly => f.object.new_record? ? false : true}
      f.input :completion_date, :label => "Date the Request has to be complete by", :as => :datepicker, :input_html => {:readonly => true}
      f.input :todo, :label => "Description"
    end
    f.buttons
  end

 show :title => "Concierge Request" do | concierge_request |
    panel "Requested Info" do
      attributes_table_for concierge_request do
        row("User") {|concierge_request| concierge_request.user.name}
        row("Email") {|concierge_request| concierge_request.user.email}
        row("Title") {|concierge_request| concierge_request.title}
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
    
    div :class => "panel" do
      panel "Reply to User" do
        render :partial =>  'reply_form'
      end
    end
  end


  action_item :only => [:show] do
    if concierge_request.workflow_state != "completed" && concierge_request.workflow_state != "rejected"
      link_to('Close Request', close_admin_concierge_request_path(concierge_request.id)) + " " + \
      link_to('Reject Request', reject_admin_concierge_request_path(concierge_request.id))
    end
  end

 member_action :reply_message, :method => :post do
    concierge_request = ConciergeRequest.find(params[:id])
    conversation = concierge_request.interactions.last.conversation
    if conversation.nil?
      raise "Conversion is Nil"
    else
      last_interaction_message = conversation.messages.last
      conversation.messages << Message.new(:subject => "Concierge Request", :body => params[:message][:body], :subject => last_interaction_message.subject)
      conversation.messages.last.sender = User.find(concierge_request.operator_id)
      conversation.messages.last.recipient = User.find(concierge_request.user_id)
      if conversation.save
        Interaction.create(:concierge_request_id => concierge_request.id, :interactable_id => conversation.messages.last.id,  :interactable_type => 'Message', :conversation_id => conversation.id)
      #self.submit!(self.user_id)
      concierge_request.on_reply!
      end
    end
    redirect_to admin_concierge_request_path(concierge_request.id)
  end

  member_action :close, :method => :get do
    concierge_request = ConciergeRequest.find(params[:id])
    concierge_request.complete!
    redirect_to admin_concierge_requests_path
  end

  member_action :reject, :method => :get do
    concierge_request = ConciergeRequest.find(params[:id])
    concierge_request.reject!
    redirect_to admin_concierge_requests_path
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

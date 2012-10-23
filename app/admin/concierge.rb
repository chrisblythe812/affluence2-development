ActiveAdmin.register PromotionsUser, :as => 'Concierge' do

  controller do
    skip_before_filter :is_admin?
  end


  menu :label => "Concierge"

  actions :all, :except => [:new,:show,:edit]

  #config.sort_order = 'user_id_desc'



  scope :concierge, :default => true



  config.clear_sidebar_sections!


  index :download_links => false  do
    column(:Member, :sortable => false){|promotions_user| promotions_user.user.name}
    column(:Profile, :sortable => false){|promotions_user| image_tag display_image(promotions_user.user.profile.photos, :thumb)}
    column('Total calls', :sortable => false) { |promotion_user| promotion_user.user.concierge_calls_count }
    column('Last Call', :sortable => false) { |concierge| global_date_format(concierge.user.concierge_last_call.created_at) }
    column('Actions', :sortable => false) do |promotions_user|
      link_to('View call history', view_call_info_admin_concierge_path(promotions_user.user)) + " | " + \
      link_to('Create new request', new_admin_concierge_request_path(:user_id => promotions_user.user.id))
    end
  end

  member_action :view_call_info,  :method => :get do
  @user = User.find(params[:id])
  @calls = @user.concierge_calls
  end

  #show do |user|
    #section "Calls made by the member" do
     #table_for @promotions_user do |concierge_call|
        #column("Name") { |promotions_user| promotions_user.user.profile.first_name }
        #column("profile") { |promotions_user| display_image(promotions_user.user.profile.photos, :thumb) }
      #end
    #end
  #end



end

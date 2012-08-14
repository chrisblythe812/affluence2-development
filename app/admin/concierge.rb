ActiveAdmin.register PromotionsUser, :as => 'Concierge' do

  menu :label => "Concierge"

  actions :all#, :except => [:new,:show,:edit]

  #config.sort_order = 'user_id_desc'



  scope :concierge, :default => true



  config.clear_sidebar_sections!


  index :download_links => false  do
    column(:Member, :sortable => false){|promotions_user| image_tag display_image(promotions_user.user.profile.photos, :thumb)}
    #column('Total calls', :sortable => false) { |promotion_user| promotion_user.calls_count }
    #column(:created_at, :sortable => false) { |concierge| global_date_format(concierge.created_at) }
    #column('Actions', :sortable => false) do |concierge|
      #link_to 'details', admin_concierge_path(concierge)
    #end
  end

  #show :title => :title do |concierge|
    #attributes_table_for concierge do
      #row :title
      #row :description
      #row :number
      #row :created_at
    #end

    #section "Members utilized this service" do
      #table_for concierge.promotion.promotions_users do |promotions_user|
        #column("Name") { |promotions_user| promotions_user.user.profile.first_name }
        #column("profile") { |promotions_user| display_image(promotions_user.user.profile.photos, :thumb) }
      #end
    #end
  #end



end

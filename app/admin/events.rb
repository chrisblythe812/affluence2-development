ActiveAdmin.register Event do

  menu :label => "Events"
  config.sort_order = "start_date_desc"
  #config.per_page = 5

  scope :up_comming, :default => true
  scope :featured
  scope :past
  #scope :active #todo it should also include the upcoming events. ex: active.up_coming
  scope :draft

  filter :title

  index do
    column("Start Date",:sortable => false) {|event| global_date_format(event.start_date)}
    column('Event',  :title,:sortable => false)
    column('Total Tickets',:tickets,:sortable => false)
    column('Tickets Remaining',:tickets_remaining,:sortable => false)
    column('Price',:sortable => false){|event| "$#{event.price}"}
    column('Actions',:sortable => false) do |event|
      link_to 'details', admin_event_path(event)
    end
  end

  config.clear_sidebar_sections!

  action_item :only => [:show] do
    link_to('View/Add Images', add_images_admin_event_path(event.id))
  end

  member_action :add_images,  :method => :get do
    @event = Event.find(params[:id])
    @promotion = @event.promotion
    @upload = Photo.new
    @photos = @event.promotion.gallery_images
    render "add_images"
  end

  member_action :update_images, :method => :post do
   @event = Event.find(params[:id])
   @upload = Photo.new(params[:upload])
   @upload.photoable_id = @event.promotion.id
   @upload.photoable_type = 'Promotion'
   if @upload.save
     render :json => { :id => @upload.id, :pic_path => @upload.image.url.to_s , :name => @upload.image.url(:medium) }, :content_type => 'text/html'
   else
     #todo handle error
     #render :json => { :result => 'error'}, :content_type => 'text/html'
   end
  end


  member_action :delete_image, :method => :get do
   photo = Photo.find(params[:id]).destroy
   event = photo.photoable.promotionable.id
   redirect_to add_images_admin_event_path(event)
  end

  show :title => :title do |event|
      attributes_table_for event do
        row :title
        row :description
        row :price
        row :start_date
        row :sale_ends_at
        row :tickets
        row :tickets_remaining
        row ('featured') {|event| event.featured? ? 'Yes' : 'No'}
        row ('Status') {|event| event.status ? 'Active' : 'Draft'}
      end

      section "Schedules for this event" do
        table_for event.schedules do |schedule|
          column("Title") { |schedule| schedule.title }
          column("Date") { |schedule| global_date_format(schedule.date) }
          column("Time") { |schedule| global_time_format(schedule.date) }
        end


      section "Includes for this event" do
        table_for event.includes do |include|
          column("Title") { |include| include.title }
        end
      end

      section "Members registered for this event" do
        table_for event.promotion.active_registered_members do |registered_member|
          column("Name") { |registered_member| registered_member.user.profile.first_name }
          column("profile"){|registered_member| display_image(registered_member.user.profile.photos, :thumb)}
          column("Date"){|registered_member| global_date_format(registered_member.created_at)}
          column("Tickets booked"){|registered_member| registered_member.total_tickets}
          column("Total price"){|registered_member| "$#{registered_member.total_amount}" }
        end
      end
      end
  end

  sidebar "Image", :only => :show do
    div do
      image_tag(event.promotion.normal_image.image.url(:medium), :style => "height:200px;width:200px;")
    end
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Create New Event" do
      f.input :title , :label => "Event Title"
      f.input :description , :label => "Event Description"
      f.input :carousel_image, :as => :file , :label =>"Upload Image(size : 870x400)"
      f.input :normal_image, :as => :file , :label =>"Upload Image(size : 360x268)"
      f.input :price, :label => "Price ($)"
      if f.object.new_record?
        f.input :tickets, :label => "Number of Tickets"
      else
        f.input :tickets_remaining, :label => "Number of Tickets Remaining"
      end
      f.input :sale_ends_at, :label => "Sale Ends"
      f.input :status,:as=> :radio, :label => "Status", :collection => [["Active",true], ["Draft",false]]
      f.input :featured,:as=> :radio, :label => "Is Featured?", :collection => [["Yes",true], ["No",false]]
    end

    f.has_many :schedules do |schedule|
      schedule.inputs  do
        schedule.input :date, :as => :datetime
        schedule.input :title
      end
    end

    f.has_many :includes do |include|
      include.inputs  do
        include.input :title
      end
    end

    f.buttons
  end

  member_action :update,  :method => :post do
    @event = Event.find(params[:id])
    update_event_photo(params[:event][:carousel_image], :carousel) unless params[:event][:carousel_image].blank?
    update_event_photo(params[:event][:normal_image]) unless params[:event][:normal_image].blank?

    if event_start_date_set? && @event.update_attributes(params[:event])
      redirect_to :action => :show, :id => @event.id
    else
      render :edit
    end
  end

  member_action :create, :method => :post do
    #Event.transaction do
    @event = Event.new(params[:event])
    construct_event
      if event_start_date_set? && @event.save
        redirect_to :action => :show, :id => @event.id
      else
        render :new
      end
     #end

  end


  controller do

    def construct_event
      promotion = @event.build_promotion
      @event.tickets_remaining = @event.tickets
      promotion.photos.build(construct_event_photo)
    end

    def construct_event_photo
      [{title: @event.title, description: @event.description, image: @event.carousel_image, image_type: 'carousel'},{title: @event.title, description: @event.description, image: @event.normal_image, image_type: 'normal'}]
    end

    def event_start_date_set?
      if !@event.schedules.first.blank? && !@event.schedules.first.date.blank?
        @event.start_date = @event.schedules.first.date.to_date
        return true
      else
        return false
      end
    end

    def update_event_photo(image,type = :normal)
       if type == :normal
         @event.promotion.normal_image.update_attributes(:image => image)
       else
         @event.promotion.carousel_image.update_attributes(:image => image)
       end
    end

  end








  
end

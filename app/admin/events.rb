ActiveAdmin.register Event do



  index do
    column("Date",:sortable => false) {|event| event.start_date.strftime("%m-%d-%y") unless event.start_date.blank?}
    column('Event',  :title,:sortable => false)
    column('Total Tickets',:tickets,:sortable => false)
    column('Tickets Remaining',:tickets,:sortable => false)
    column('Price',:sortable => false){|event| "$#{event.price}"}
    column('Actions',:sortable => false) do |event|
      link_to 'details', admin_event_path(event)
    end
  end

  config.clear_sidebar_sections!



  form :html => { :enctype => "multipart/form-data" } do |f|
    #f.object.build_promotion
    f.inputs "Create New Event" do
      f.input :title , :label => "Event Title"
      f.input :description , :label => "Event Description"
      f.input :image, :as => :file , :label =>"Add Pictures"
      f.input :price
      f.input :tickets, :label => "Number of Tickets"
      f.input :sale_ends_at, :label => "Sale Ends"
    end

    #f.has_many :includes do |include|

    #end



    f.has_many :schedules do |schedule|
      schedule.inputs  do
        schedule.input :date, :as => :datetime
        #schedule.input :time, :as => :time
        schedule.input :title
      end
    end

    f.buttons
  end
  
end

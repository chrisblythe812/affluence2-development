ActiveAdmin.register Offer do

  menu :label => "Offers"
  menu false


  scope :all, :default => true
  scope :active
  scope :dinning
  scope :travel
  scope :financial
  scope :shopping
  scope :services

  config.clear_sidebar_sections!

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Create New Offer" do
      f.input :title , :label => "Offer Title"
      f.input :description , :label => "Offer Description"
      f.input :offer_image, :as => :file , :label =>"Upload Image(size : 210x100)"
      f.input :link, :label => "Offer Link"
      f.input :active,:as => :radio, :label => "Is this is an Active Offer?", :collection => [["Active",true], ["Disable",false]]
      f.input :featured,:as => :radio, :label => "Is this is a Featured Offer?", :collection => [["Featured",true], ["Disable",false]]
      f.input :category,:as => :select, :collection => [['Travel', 'Travel'], ['Services', 'Services'], ['Financial','Financial'],['Shopping','Shopping'],['Dinning','Dinning']], :include_blank => false
    end
    f.buttons
  end

  member_action :create, :method => :post do
    @offer = Offer.new(params[:offer]) unless params[:offer].blank?
    create_offer_object
    @offer.save!
    redirect_to :action => :show, :id => @offer.id
  end

  member_action :update,  :method => :post do
    @offer = Offer.find(params[:id]) unless params[:id].blank?
    update_offer_photo(params[:offer][:offer_image])
    if @offer.update_attributes(params[:offer])
      redirect_to :action => :show, :id => @offer.id
    else
      render :edit
    end
  end
  
  controller do
    def create_offer_object
      promotion = @offer.build_promotion 
      promotion.photos.build(save_offer_photo)
    end


    def save_offer_photo
      [{title: @offer.title, description: @offer.description, image: @offer.offer_image, image_type: 'normal'}] 
    end

    def update_offer_photo(image)
      @offer.promotion.offer_image.update_attributes(:image => image)
    end
  end


  
end

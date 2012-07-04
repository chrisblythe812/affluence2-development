ActiveAdmin.register Promotion do

  #menu :if => proc{ Rails.env.development? }
  menu false


  form :html => {:enctype => "multipart/form-data"} do |f|
    f.inputs "Upload Images" do

    end

    f.has_many :photos do |photo|
      photo.inputs do
        photo.input :image, :as => :file, :label => "Add Pictures"
      end
    end

    f.buttons
  end

end

class WineShare < ActiveRecord::Base

  belongs_to :vincompass_share

  #attr_accessor :photo_url

  #attr_accessor :wine_name, :year, :region, :grape, :producer, :link, :comment,:restaurant_name, :photo_url


  #has_one :photo, :as => :photoable, :dependent => :destroy

  #before_create :attach_photo

  #def check_photo_url
  #self.photo = download_remote_image unless photo_url.blank?
  #self.photo_remote_file_url = photo_url unless self.photo.nil?
  #end

  #def download_remote_image
  #io = open(URI.parse(photo_url))
  #def io.original_filename; base_uri.path.split('/').last; end
  #io.original_filename.blank? ? nil : io
  #rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  #end

  #def attach_photo
  #puts "--------#{photo_url}"
  #build_photo(:photo => download_remote_image) unless photo_url.blank?
  #end

end

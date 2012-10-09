class PhotoStreamsController < ApplicationController
before_filter :authenticate_user!
before_filter :authenticate_paid_user!

  def index
   if current_user.profile.photo_streams.blank?
     current_user.profile.photo_streams.build.save!
   end
     redirect_to user_photo_stream_path(current_user.permalink, current_user.profile.photo_streams.first)
  end


  def show
    @photostream = current_user.profile.photo_streams.first
    @photo = @photostream.photos.build 
  end

  def create_photo
    p params
    @photostream = current_user.profile.photo_streams.find(params[:photo_stream_id])
    @photo = @photostream.photos.build(:image => params[:upload][:image])
    if @photo.save!
      p '----------'
      p @photo

       render :json => {:id => @photo.id, :pic_path => @photo.image.url.to_s, :name => @photo.image.url(:medium)}, :content_type => 'text/html'
    end
  end
  def destroy_photo
    photo = Photo.find(params[:id]).destroy
    redirect_to user_photo_stream_path(current_user.permalink, photo.photoable)
  end

end

class PhotoStreamObserver < ActiveRecord::Observer
  def after_save(profile)
    PhotoStreamActivity.create(:user_id => profile.user,
                               :body => 'has uploaded ',
                               :resource_type => 'PhotoStream',
                               :resource_id => profile.photo_stream.id)
  end

end

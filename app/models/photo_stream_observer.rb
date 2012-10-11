class PhotoStreamObserver < ActiveRecord::Observer
  def after_save(photo_stream)
    activity = Activity.new(:user_id => photo_stream.profile.user.id,
                               :body => 'has uploaded ',
                               :resource_type => 'PhotoStream',
                               :resource_id => photo_stream.id)
    activity.save!
  end
end

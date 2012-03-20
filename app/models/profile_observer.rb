class ProfileObserver < ActiveRecord::Observer
  def after_save(profile)
    Activity.create(:user_id  => profile.user,
                           :body => 'has updated his profile',
                           :resource_type => 'Profile',
                           :resource_id => profile.id)
  end  
end


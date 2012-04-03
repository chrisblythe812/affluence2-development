class ProfileObserver < ActiveRecord::Observer
  def after_save(profile)
    Activity.create(:user_id  => profile.user.id,
                           :body => 'has updated his profile information',
                           :resource_type => 'Profile',
                           :resource_id => profile.id)
  end  
end


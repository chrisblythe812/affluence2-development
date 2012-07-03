class DiscussionObserver < ActiveRecord::Observer
  def after_create(discussion)

    Activity.create(:user_id  => discussion.user_id,
                           :body => discussion.user.profile.name + ' has posted a new discussion',
                           :resource_type => 'Discussion',
                           :resource_id => discussion.id)
  end
end

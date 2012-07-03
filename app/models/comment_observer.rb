class CommentObserver < ActiveRecord::Observer
def after_create(comment)

    Activity.create(:user_id  => comment.user_id,
                           :body => comment.user.profile.name + ' has posted a new comment',
                           :resource_type => 'Comment',
                           :resource_id => comment.id)
  end
end

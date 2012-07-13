class ConnectionObserver < ActiveRecord::Observer

  def after_create(connection)
    Activity.create(:user_id => connection.user_id,
                    :body => connection.user.profile.name + ' is now connected to ',
                    :resource_type => 'Connection',
                    :resource_id => connection.id)
#
#    reciprocate_connection(connection)
#    remove_associated_friend_requests(connection)
#    send_connection_approved_email(connection)
#    create_connection_activity(connection)
  end

  def after_destroy(connection)
#    remove_reciprocated_connection(connection)
  end

#private

  def send_connection_approved_email(connection)

    # Since a friend can only be added after accepting a friend
    # request, we can assume the connection object passed into this method
    # is from the perspective of the accepting friend, or requestee.  Since this
    # is the case, the first parameter to the following method, and the one whom
    # will receive the approval email is the "friend" in the connection.
    UserMailer.delay.connection_approved_email(connection.friend, connection.user)
  end

  def reciprocate_connection(connection)
    connection.create(:user => connection.friend, :friend => connection.user, :skip_observer => true)
  end

  def remove_associated_friend_requests(connection)
    user_id, friend_id = connection.user_id, connection.friend_id
    conditions_str = "(requestor_id = ? and requestee_id = ?) or (requestor_id = ? and requestee_id = ?)"
    FriendRequest.delete_all([conditions_str, user_id, friend_id, friend_id, user_id])
  end

  def remove_reciprocated_connection(connection)
    connection.delete_all(["user_id = ? and friend_id = ?", connection.friend_id, connection.user_id])
  end

  def create_connection_activity(connection)
    ConnectionActivity.create(:user => connection.friend,
                              :target_user => connection.user)
  end

end

class ConnectionRequestObserver < ActiveRecord::Observer
#  def after_create(conversation_request)
#    if conversation_request.requestee.prefers_new_conversation_request_notifications?
#      UserMailer.delay.friend_request_email(conversation_request.requestor, conversation_request.requestee)
#    end
#  end
end


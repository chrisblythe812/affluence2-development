class MessageObserver < ActiveRecord::Observer
#  def after_save(message)
#    Activity.create(:user_id  => message.sender_id,
#                           :body => 'has sent a message',
#                           :resource_type => 'Message',
#                           :resource_id => message.sender_id)
#  end
 end  

class MessageObserver < ActiveRecord::Observer
  def after_create(message)
   if message.recipient.role == 'superadmin'
     create_interaction_thread(message)
   end
  end


  def create_interaction_thread(message)
    puts "message - #{message.inspect}"
   #get the last message to find the conversation request record.
   last_message = Message.find(:last, :conditions => ["sender_id = ? and recipient_id = ?",message.recipient_id, message.sender_id])
   if !last_message.blank?
     puts "last message - #{last_message.inspect}"
   # find the interaction with the last_message id
   interaction = Interaction.find(:last, :conditions => ["interactable_type = ?  and interactable_id = ?", 'Message', last_message.id])
   # create new interaction with above interaction.concierge_request and latest message
   if !interaction.blank?
     puts "interaction - #{interaction.inspect}"
     Interaction.create(:concierge_request_id => interaction.concierge_request_id, :interactable_id => message.id,  :interactable_type => 'Message')
     interaction.concierge_request.on_message!
   end
   end

   #raise "error"
  end
 end 

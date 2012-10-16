class ConciergeRequest < ActiveRecord::Base

  validates_presence_of :user_id, :operator_id, :request_note, :completion_date

  belongs_to :user

  has_many :interactions


  after_create :create_interaction


  #create interaction with type message.
  #create new conversation if not exists and send the request as message to user.
  def create_interaction
    conversation = Conversation.get_conversation_for(self.operator_id, self.user_id).first
    if conversation.nil?
      conversation = Conversation.new(:messages_attributes => { "0" => { "body" => self.request_note}})
    else
      conversation.messages << Message.new(:subject => "Concierge Request", :body => self.request_note)
    end
    conversation.messages.last.sender = User.find(self.operator_id)
    conversation.messages.last.recipient = User.find(self.user_id)
    if conversation.save
     Interaction.create(:concierge_request_id => self.id, :interactable_id => conversation.messages.last.id,  :interactable_type => 'Message')
     self.submit!(self.user_id)
     self.on_reply!
    end
  end




  include Workflow
  workflow do
    state :new do
      event :submit, :transitions_to => :awaiting_operator do |user_id|
        # Allow only one active concierge-request per user
        halt! "The #{user_id} already has a concierge-request" unless ConciergeRequest.matching_requests(user_id) == nil
      end
    end

    state :awaiting_operator do
      event :on_reply, :transitions_to => :awaiting_customer
      event :complete, :transitions_to => :completed
      event :reject, :transitions_to => :rejected
    end
    on_exit do
      #TODO mail the user
      puts " buildMessage  and mail to customer"
    end

    state :awaiting_customer do
      event :on_message, :transitions_to => :awaiting_operator
    end
    on_exit do
      #TODO mail to the operator
      puts " buildMessage  and mail to operator"
    end

    state :completed
    state :rejected

    on_transition do |from, to, triggering_event, *event_args|
      #TODO log this transition
      puts "#{from} -> #{to}"
    end

  end

  def self.matching_requests(user_id)
    where("user_id = ? and workflow_state in (?, ?)",user_id,:awaiting_operator,:awaiting_customer).first
  end













end

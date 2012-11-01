class ConciergeRequest < ActiveRecord::Base

  validates_presence_of :user_id, :operator_id, :request_note, :completion_date, :title
  belongs_to :user

  has_many :interactions

  after_create :create_unique_code, :create_interaction
  validate :validate_completion_date
  
 scope :my_requests, lambda{|user_id| where(["operator_id =? and workflow_state != ? and workflow_state != ?", user_id, "completed", "rejected"])}
 scope :completed, lambda{|user_id=nil|
    if user_id
      where(["operator_id = ? and workflow_state = ?",user_id, "completed"])
    else
      where(["workflow_state = ?", "completed"])
     end
    }
  scope :rejected, lambda{|user_id=nil|
    if user_id
      where(["operator_id = ? and workflow_state = ?",user_id, "rejected"])
    else
      where(["workflow_state = ?", "rejected"])
     end
    }
  scope :active_users , select("users.id, (profiles.first_name || ' ' || profiles.last_name) as name").joins(:user => :profile).group("users.id,name").order("name asc")
  
  #create interaction with type message.
  #create new conversation if not exists and send the request as message to user.
  def create_interaction
    conversation = Conversation.get_conversation_for(self.operator_id, self.user_id).first
    if conversation.nil?
      conversation = Conversation.new(:messages_attributes => { "0" => { "body" => self.request_note, :subject => self.title}})
    else
      conversation.messages << Message.new(:subject => self.title, :body => self.request_note)
    end
    conversation.messages.last.sender = User.find(self.operator_id)
    conversation.messages.last.recipient = User.find(self.user_id)
    if conversation.save
     Interaction.create(:concierge_request_id => self.id, :interactable_id => conversation.messages.last.id,  :interactable_type => 'Message')
     self.submit!(self.user_id)
     self.on_reply!
    end
  end
  
  def self.join_user_profile
    self.joins(:user => :profile).order("concierge_requests.completion_date desc")
  end

  def create_unique_code
    unique_code = "CR#{self.id}"
    subject = unique_code + ":" + self.title
    self.update_attributes(:code => unique_code , :title => subject)
  end
  
  def validate_completion_date
    if completion_date.to_date < Date.today
      errors.add(:completion_date, "invalid date")
    end
  end
  
  def self.all_status
    ["awaiting_customer","awaiting_operator" ,"completed", "rejected" ]  
  end
  
  include Workflow
  workflow do
    state :new do
      event :submit, :transitions_to => :awaiting_operator do |user_id|
        # Allow only one active concierge-request per user
        # halt! "The #{user_id} already has a concierge-request" unless ConciergeRequest.matching_requests(user_id) == nil
      end
    end

    state :awaiting_operator do
      event :on_reply, :transitions_to => :awaiting_customer
      event :complete, :transitions_to => :completed
      event :reject, :transitions_to => :rejected
      event :on_message, :transitions_to => :awaiting_operator
    end
    on_exit do
      #TODO mail the user
      puts " buildMessage  and mail to customer"
    end

    state :awaiting_customer do
      event :on_message, :transitions_to => :awaiting_operator
      event :on_reply, :transitions_to => :awaiting_customer
      event :complete, :transitions_to => :completed
      event :reject, :transitions_to => :rejected
    end
    on_exit do
      #TODO mail to the operator
      puts " buildMessage  and mail to operator"
    end

    state :completed do
      event :on_message, :transitions_to => :completed
      event :on_reply, :transitions_to => :completed
    end
    state :rejected do
      event :on_message, :transitions_to => :rejected
      event :on_reply, :transitions_to => :rejected
    end

    on_transition do |from, to, triggering_event, *event_args|
      #TODO log this transition
      puts "Custom #{from} -> #{to}"
    end

  end

  def self.matching_requests(user_id)
    where("user_id = ? and workflow_state in (?, ?)",user_id,:awaiting_operator,:awaiting_customer).first
  end













end

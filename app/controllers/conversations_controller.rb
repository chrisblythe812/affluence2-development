class ConversationsController < ApplicationController
  autocomplete :profile , :full_name, :extra_data => [:id]
#  include Tabs
#  layout "conversations"
  before_filter :set_page_header

  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.where("user_id != ?", current_user.id)
  end

  def index
    tab_page = params[:tab_page] ? params[:tab_page].to_sym : :inbox
    set_tab(tab_page, :messages)
    if params[:blitz]
      @user = User.where(:email => "blake.macleod@gmail.com").first
      sign_in(@user)
    else
      raise CanCan::AccessDenied if params[:user_id].to_i != current_user.id
    end
    if tab_page == :inbox
      @conversations = Conversation.for_user(current_user).archived?(false).page params[:page]
    elsif tab_page == :archive
      @conversations = Conversation.for_user(current_user).archived?(true).page params[:page]
    end
  end

  def new
    @conversation = Conversation.new
    if @recipient = Profile.find_by_id(params[:to]).user rescue nil
      @conversation.messages.build(:recipient => @recipient)
    else

      @conversation.messages.build
    end
  end

  def show
    @conversation = Conversation.find(params[:id], :include => :messages)
    status = @conversation.archived?(current_user)
    @other_conversations = Conversation.for_user(current_user).archived?(status)
    @first_message = @conversation.messages.first
    @replies = @conversation.messages
#    @replies.shift

#    authorize!(:view, @conversation)
    @conversation.messages.build
    unless @conversation.read?(current_user)
      session[:unread_messages_count] -= 1 if @conversation.mark_as_read!(current_user)
    end
  end

  def create
    recipient_user = Profile.find(params[:conversation][:recipient_profile_id])[0].user rescue nil
    params[:conversation].delete(:recipient_profile_id)
    @conversation = Conversation.new(params[:conversation])
    if !recipient_user.blank? && recipient_user.profile.full_name == params[:conversation][:messages_attributes]["0"][:recipient_name]
      @conversation.messages.first.sender = current_user
      @conversation.messages.first.recipient = recipient_user
      ConnectionRequest.create(:requestor => current_user, :requestee_id => recipient_user.id)

#      authorize!(:create, @conversation.messages.first)

      if @conversation.save
        redirect_to user_conversations_path(current_user), :flash => {:notice => "Your message has been sent."}
      else
        render :new
      end
    else
      flash[:notice] = "Cannot send message to that user or user does not exist."
      render :new
    end
  end

  def update
    @conversation = Conversation.find(params[:id])

    recipient = @conversation.recipient_for(current_user)

#    authorize! :edit, @conversation
    previous_message = @conversation.messages.last
    new_message_attrs = {}
    new_message_attrs[:body] = params[:message][:body]
    new_message_attrs[:subject] = previous_message.subject
    new_message_attrs[:sender_id] = current_user.id
    new_message_attrs[:recipient_id] = recipient.id
    new_message_attrs[:conversation_id] = @conversation.id

    if current_user != recipient
      Connection.make_connection(current_user, recipient)
      Connection.make_connection(recipient, current_user)
    end
#
#
##    authorize!(:create, Message)

    if @message = Message.create(new_message_attrs)
      @conversation.messages << @message
      redirect_to user_conversations_path(current_user), :flash => {:notice => "Your message has been sent."}
    else
      render :show
    end
  end

  def archive
    @conversation = Conversation.find(params[:conversation_id])

    authorize! :edit, @conversation

    @conversation.archive!(current_user)

    respond_to do |format|
      format.html { redirect_to user_conversations_path(current_user), :flash => {:notice => "Conversation has been archived."} }
      format.js { render :layout => false }
    end
  end

  def unarchive
    @conversation = Conversation.find(params[:conversation_id])

    authorize! :edit, @conversation

    @conversation.unarchive!(current_user)

    respond_to do |format|
      format.html { redirect_to user_conversations_path(current_user), :flash => {:notice => "Conversation has been unarchived."} }
      format.js { render :nothing => true }
    end
  end

  private
  def set_page_header
    @page_header = "Messages"
  end
end

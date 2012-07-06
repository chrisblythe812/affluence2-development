class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authenticate_paid_user!, :except => [:index, :show, :confirm]
  before_filter :set_page_header
  autocomplete :profile, :full_name, :extra_data => [:id]


  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = Profile.joins(:user).where("LOWER(profiles.full_name) ilike ? and status = ? and user_id != ?", "#{params[:term]}%", "active", current_user.id).order("profiles.full_name").limit(10).select(["profiles.id", "profiles.full_name"])
  end

  def index
    @conversation = Conversation.new
    @conversation.messages.build
    @conversations = Conversation.joins(:conversation_metadata).where("conversation_metadata.user_id = ?", current_user.id).archived?(false).order("updated_at DESC").page params[:page]

    #    tab_page = params[:tab_page] ? params[:tab_page].to_sym : :inbox
    #    set_tab(tab_page, :messages)
    #    if params[:blitz]
    #      @user = User.where(:email => "blake.macleod@gmail.com").first
    #      sign_in(@user)
    #    else
    #      raise CanCan::AccessDenied if params[:user_id].to_i != current_user.id
    #    end
    #    if tab_page == :inbox
    #          @conversations = Conversation.for_user(current_user).archived?(false).page params[:page]
    #    elsif tab_page == :archive
    #      @conversations = Conversation.for_user(current_user).archived?(true).page params[:page]
    #    end
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
    @conversations = Conversation.for_user(current_user)
    @conversation = Conversation.find(params[:id], :include => :messages)
    if @conversations.include? @conversation

      status = @conversation.archived?(current_user)
#      @other_conversations = Conversation.for_user(current_user).archived?(status)
      @first_message = @conversation.messages.first
      @replies = @conversation.messages.order('updated_at asc')
      #    @replies.shift

      #    authorize!(:view, @conversation)
      @conversation.messages.build
      unless @conversation.read?(current_user)
        session[:unread_messages_count] -= 1 if @conversation.mark_as_read!(current_user)
      end
    elsif current_user.plan == 'free'
      flash[:error] = "Cannot send message, Please become a premium member."
    else
      redirect_to user_conversations_path(current_user), :flash => {:error => "Unauthorized Access!"}
    end
  end

  def create
    recipient_user = Profile.find(params[:conversation][:recipient_profile_id])[0].user rescue nil
    params[:conversation].delete(:recipient_profile_id)
    if !recipient_user.blank? && recipient_user.profile.full_name == params[:conversation_recipient_profile_name]

    @conversation = Conversation.get_conversation_for(current_user.id, recipient_user.id).first
    if @conversation.nil?
      @conversation = Conversation.new(params[:conversation])

    else
      #      @conversation = message.conversation
      @conversation.messages << Message.new(params[:conversation][:messages_attributes]["0"])

    end

      @conversation.messages.last.sender = current_user
      @conversation.messages.last.recipient = recipient_user
      #      ConnectionRequest.find_or_create_by_requestor_id_and_requestee_id(current_user.id, recipient_user.id)

      #      authorize!(:create, @conversation.messages.first)

      if @conversation.save
        redirect_to user_conversations_path(current_user), :flash => {:success => "Your message has been sent."}
      else
        render :new
      end
    else
      @conversation = Conversation.new
      @conversation.messages.build
      flash[:error] = "Cannot send message to that user or user does not exist."
      render :new
    end
  end

  def update
    logger.info 'ssssssssssssssssssssss'
    logger.info params
    @conversation = Conversation.find(params[:id])
    #    @conversation = Conversation.get_conversation_for(current_user.id, recipient_user.id).first

    recipient = @conversation.recipient_for(current_user)

    #    authorize! :edit, @conversation
    previous_message = @conversation.messages.last
    new_message_attrs = {}
    new_message_attrs[:body] = params[:message][:body]
    new_message_attrs[:subject] = previous_message.subject
    new_message_attrs[:sender_id] = current_user.id
    new_message_attrs[:recipient_id] = recipient.id
    new_message_attrs[:conversation_id] = @conversation.id

    #    if previous_message.sender_id != current_user.id
    #      Connection.make_connection(current_user, recipient)
    #      Connection.make_connection(recipient, current_user)
    #    end
    #
    #
    ##    authorize!(:create, Message)

    if @message = Message.create(new_message_attrs)
      @conversation.messages << @message
      @conversation.save
      redirect_to user_conversations_path(current_user), :flash => {:success => "Your message has been sent."}
    else
      render :show
    end
  end

  def archive
    @conversation = Conversation.find(params[:conversation_id])

#    authorize! :edit, @conversation

    @conversation.archive!(current_user)

    respond_to do |format|
      format.html { redirect_to user_conversations_path(current_user), :flash => {:success => "Conversation has been archived."} }
      format.js { render :layout => false }
    end
  end

  def unarchive
    @conversation = Conversation.find(params[:conversation_id])

    authorize! :edit, @conversation

    @conversation.unarchive!(current_user)

    respond_to do |format|
      format.html { redirect_to user_conversations_path(current_user), :flash => {:success => "Conversation has been unarchived."} }
      format.js { render :nothing => true }
    end
  end

  # will be called when free user tries to subscribe before offer activation.
  def confirm
    begin
      @result = Braintree::TransparentRedirect.confirm(request.query_string)
      if @result.success?
        current_user.update_user_with_plan_and_braintree_id(session[:user_plan], @result.customer.id)
        session[:user_plan]=nil
        flash[:success] = "You have successfully converted to paid member. Now you can send messages"
        redirect_to user_conversations_path(current_user.id)
      else
        flash[:error] = "Your payment was not success. Check your card information."
        redirect_to user_conversations_path(current_user.id)
      end
    rescue
      flash[:error] = "Your payment was not success. Check your card information."
      redirect_to user_conversations_path(current_user.id)
    end
  end


  private
  def set_page_header
    @page_header = "Messages"
  end


end

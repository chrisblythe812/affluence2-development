class DiscussionsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @discussion = Discussion.new
    if !params[:search].blank?
      query = Discussion.build_search_query(params[:search])
      records = Discussion.search_with_comments(query)
      @discussions = Kaminari.paginate_array(records).page(params[:page]).per(10)
      @discussions_size = records.count
      @search = true
    elsif params[:id]
      @discussions = Discussion.where(:id => params[:id]).page(params[:page]).per(10)
    else
      @discussions = Discussion.includes(:comments).order("last_comment_at Desc").page(params[:page]).per(10)
      @discussions_size  = @discussions.total_count
    end
  end


  def new
  end

  def create
    params[:discussion][:question].strip! unless params[:discussion][:question].nil?
    @discussion = Discussion.new(params[:discussion])
    @discussion.user_id = current_user.id
 
    respond_to do |format|
      if @discussion.save
        @discussion.last_comment_at = @discussion.created_at
        @discussion.save
        flash[:success]= "Discussion was successfully created."
        format.html { redirect_to discussions_path }
        format.json { head :ok }
      else
        flash[:error]= "Discussion was not created."
        format.html { render action: "index" }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @discussion = Discussion.find_by_id(params[:id].to_i)
    if !@discussion.blank?
    comments = params[:discussion][:comments]
    comments["user_id"] = current_user.id
    @discussion.comments.build(comments)
    respond_to do |format|
      if @discussion.save
        @discussion.last_comment_at = @discussion.comments.last.created_at
        @discussion.save
        flash[:success]= "Reply was successfully posted."


        format.html { redirect_to discussions_path }
        format.json { head :ok }
      else
        flash[:error]= "Unable to post the reply."

        format.html { redirect_to discussions_path }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
    else
      flash[:notice]= "Your comment was not posted as the Discussion was deleted."
      redirect_to discussions_path and return
    end
  end

end

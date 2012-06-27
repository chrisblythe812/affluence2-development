class DiscussionsController < ApplicationController
  before_filter :authenticate_user!
  def index
      @discussion = Discussion.new
    unless params[:search].blank?
      @discussions =   Kaminari.paginate_array(Discussion.search(params[:search])).page(params[:page]).per(3)
      @discussions_size = Discussion.search(params[:search]).size
      @search = true
    else
      @discussions_size = Discussion.all.size
      @discussions = Kaminari.paginate_array(Discussion.all(:include => :comments, :order =>"last_comment_at Desc")).page(params[:page]).per(10)
    end
  end

  


  def new
  end

  def create
    params[:discussion][:question].strip!  unless params[:discussion][:question].nil?
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
        format.html { render action: "index"}
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @discussion = Discussion.find(params[:id].to_i)
     
    params[:discussion][:comments]
    comments = params[:discussion][:comments]
    comments["user_id"] = current_user.id 
    @discussion.comments.build(comments)
    respond_to do |format|
      if @discussion.save
        @discussion.last_comment_at = @discussion.comments.last.created_at
        @discussion.save
        flash[:success]= "Reply was successfully created."


        format.html { redirect_to discussions_path}
        format.json { head :ok }
      else
        flash[:error]= "Reply was not created."

        format.html { redirect_to discussions_path }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end
end

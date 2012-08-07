ActiveAdmin.register Discussion do

  menu :label => "Discussions"
  config.sort_order = "updated_at"

  actions :all, :except => [:new]

  filter :title

  before_filter :only => :index do
    @per_page = 10
  end


  index :download_links => false do
    column("Question", :sortable => false) { |discussion| discussion.question }
    column('Posted By', :sortable => false){ |discussion| discussion.user.name }
     column('Comments', :sortable => false){ |discussion| discussion.comments.count }
    column('Created on', :sortable => false){ |discussion|  global_date_format(discussion.created_at) }
    column('Actions', :sortable => false) do |discussion|
      link_to 'view', admin_discussion_path(discussion)
    end
  end

  config.clear_sidebar_sections!



  show :question => :question do |discussion|
    attributes_table_for discussion do
      row :question
      row("Created on") { |discussion|  global_date_format(discussion.created_at) }
      row("Created by") { |discussion|  discussion.user.name }
      row("Last commented on") { |discussion|  global_date_format(discussion.last_comment_at) }
    end

    section "Comments for this discussion" do
      table_for discussion.comments do |comment|
        column("Comment") { |comment| comment.body }
        column("Posted By") { |comment| comment.user.name }
        column("Date") { |comment| global_date_format(comment.created_at) }
      end
    end
  end


end

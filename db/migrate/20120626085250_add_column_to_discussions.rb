class AddColumnToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :last_comment_at, :timestamp
  end
end

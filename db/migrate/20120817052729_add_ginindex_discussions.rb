class AddGinindexDiscussions < ActiveRecord::Migration
  def up
    execute "CREATE INDEX discussions_gin_question ON discussions USING GIN(to_tsvector('english', question))"
    execute "CREATE INDEX comments_gin_body ON comments USING GIN(to_tsvector('english', body))"
  end

  def down
    execute "DROP INDEX discussions_gin_question"
    execute "DROP INDEX comments_gin_body"
  end
end

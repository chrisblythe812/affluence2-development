class AddIndicesForMessagesSearch < ActiveRecord::Migration
  def up

    execute <<-SQL
      CREATE INDEX messages_all_search_gin_idx_english ON messages
        USING gin(to_tsvector('english',        COALESCE(subject,'') || ' ' ||   COALESCE(body,'') ));

    SQL
  end

  def down
    execute "DROP INDEX messages_all_search_gin_idx_english"
  end
end

class AddIndicesForSearch < ActiveRecord::Migration
  def self.up
    add_index(:taggings,[:taggable_type,:tag_id])
    execute <<-SQL
      CREATE INDEX profiles_all_search_gin_idx_english ON profiles
        USING gin(to_tsvector('english',
        COALESCE(first_name,'') || ' ' ||
        COALESCE(last_name,'') || ' ' ||
        COALESCE(bio,'') || ' ' ||
        COALESCE(city,'') || ' ' ||
        COALESCE(state,'') || ' ' ||
        COALESCE(country,'') || ' ' ||
        COALESCE(title,'') || ' ' ||
        COALESCE(company,'' )));
      CREATE INDEX tags_search_gin_idx_english ON tags USING gin(to_tsvector('english', name));
    SQL
  end


  def self.down
    remove_index(:taggings,[:taggable_type,:tag_id])
    execute <<-SQL
      DROP INDEX profiles_all_search_gin_idx_english;
      DROP INDEX tags_search_gin_idx_english;
    SQL
  end

end

require 'rubygems'
require 'active_record'
require 'logger'
  



namespace :affluence2 do
  desc "Will reindex ......"
  task :reindex => :environment do
    migration = ActiveRecord::Migration
    p 'removing index....'
    migration.remove_index("connections", ["friend_id", "user_id"]) if migration.index_exists?("connections", ["friend_id", "user_id"])
    migration.remove_index "connections", ["friend_id"] if migration.index_exists?("connections", ["friend_id"])
    migration.remove_index "connections", ["user_id"] if migration.index_exists?("connections", ["user_id"])

    p 'adding index....'
    migration.add_index "connections", ["friend_id", "user_id"]
    migration.add_index "connections", ["friend_id"]
    migration.add_index "connections", ["user_id"]


    p ''
    p ''
    #TODO profile indexing
    p ' ------------------------ profiles indexing for search  ------------------------  '
    migration.execute <<-SQL
      DROP INDEX profiles_all_search_gin_idx_english;

      CREATE INDEX profiles_all_search_gin_idx_english 
      ON profiles
      USING gin(to_tsvector('english', COALESCE(first_name,'') || ' ' ||
                                       COALESCE(last_name,'') || ' ' ||
                                       COALESCE(title,'') || ' ' ||
                                       COALESCE(company,'') || ' ' ||
                                       COALESCE(city,'') || ' ' ||
                                       COALESCE(state,'') || ' ' ||
                                       COALESCE(country,'') || ' ' ||
                                       COALESCE(bio,'' )));
    SQL
  
    p '------------------------ profiles indexing for autocomplete ------------------------ '
    if migration.index_exists?("profiles", ["user_id"])
      migration.remove_index("profiles", ["user_id"])     
    end
  
    if migration.index_exists?("profiles", ["full_name"])
      migration.remove_index "profiles", ["full_name"]
    end

    migration.add_index "profiles", ["user_id"]
    migration.add_index "profiles", ["full_name"]

    p ''
    p ''
    #TODO Discussions indexing
    p '------------------------ Discussions indexing ------------------------ '
    if migration.index_exists?("discussions", ["user_id"])
      migration.remove_index("discussions", ["user_id"])
    end

    if migration.index_exists?("discussions", ["question"])
      migration.remove_index "discussions", ["question"]
    end

    migration.add_index "discussions", ["user_id"]
    migration.add_index "discussions", ["question"]


    p ''
    p ''
    #TODO Activity indexing
    p '------------------------ Activity indexing ------------------------ '
    if migration.index_exists?("activities", ["user_id"])
      migration.remove_index("activities", ["user_id"])
    end

    if migration.index_exists?("activities", ["resource_id"])
      migration.remove_index "activities", ["resource_id"]
    end

    if migration.index_exists?("activities", ["resource_type"])
      migration.remove_index "activities", ["resource_type"]
    end

    migration.add_index "activities", ["user_id"]
    migration.add_index "activities", ["resource_id"]
    migration.add_index "activities", ["resource_type"]


    p ''
    p ''
    #TODO conversation_metadata indexing
    p '------------------------ ConversationMetadatum indexing ------------------------ '

    if migration.index_exists?("conversation_metadata", ["user_id"])
      migration.remove_index("conversation_metadata", ["user_id"])
    end

    migration.add_index "conversation_metadata", ["user_id"]
   end
end

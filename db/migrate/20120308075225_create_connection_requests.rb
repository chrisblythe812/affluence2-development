class CreateConnectionRequests < ActiveRecord::Migration
  def change
    create_table :connection_requests do |t|
      t.integer  "requestor_id", :null => false
      t.integer  "requestee_id", :null => false
 
      t.timestamps
    end
  add_index "connection_requests", ["requestee_id"], :name => "index_connection_requests_on_requestee_id"
  add_index "connection_requests", ["requestor_id"], :name => "index_connection_requests_on_requestor_id"
  end
end

class AddCodeToConcierageRequest < ActiveRecord::Migration
  def up
    add_column :concierge_requests, :code, :string
    ConciergeRequest.reset_column_information
    ConciergeRequest.all.each do |cr|
      cr.update_attributes(:code => "CR#{cr.id}", :title => ("CR#{cr.id}" + "-" + cr.title.to_s))
    end 
  end
  
  def down
    remove_column :concierge_requests, :code
  end
end

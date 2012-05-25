class AddOfferColumnstoOffer < ActiveRecord::Migration
  def change
    add_column :offers, :link, :text
    add_column :offers, :active, :boolean
    add_column :offers, :featured, :boolean
    add_column :offers, :category, :string
  end
end

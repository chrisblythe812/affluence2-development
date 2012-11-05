class AddConversationIdForInteractions < ActiveRecord::Migration
  def up
    add_column :interactions , :conversation_id , :integer
    Interaction.reset_column_information
    Interaction.all.each do |i|
      i.update_attribute(:conversation_id , i.interactable.conversation_id)
    end
    add_index :interactions, :conversation_id, :name => 'index_interactions_on_conversation_id'
  end

  def down
    remove_column :interactions, :conversation_id
  end
end

class Interaction < ActiveRecord::Base


  belongs_to :concierge_request

  belongs_to :interactable, :polymorphic => true, :dependent => :destroy

end

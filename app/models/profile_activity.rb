class PhotoStreamActivity < Activity
  belongs_to :resource, :polymorphic => true
end

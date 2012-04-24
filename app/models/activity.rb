class Activity < ActiveRecord::Base
  belongs_to :user 
  belongs_to :resource, :polymorphic => true

  scope :previous, lambda { |p| {:conditions => ["id < ?", p.id], :limit => 1, :order => "id DESC"} }
  scope :next, lambda { |p| {:conditions => ["id > ?", p.id], :limit => 1, :order => "id"} }

  OPTS = {
    "Event" => "events",
    "Offer" => "offers",
    "Connection" => "new_contact",
    "Photo" => "photos",
    "Invitation" => "invitations"
  }
#  def self.all_by_privacy_setting
#    activities = []
#    begin
#      activity = activity ? self.previous(activity).first : self.last
#      privacy =  activity.user.profile.privacy_setting
#
#      activities << activity if [0, 1].include? privacy.send(OPTS[activity.resource_type])
#    end while activities.length < 7
#
#    activities
#
#  end
def self.all_by_privacy_setting
    activities = []
    begin
      activity = activity ? self.previous(activity).first : self.last
      privacy =  activity.user.profile.privacy_setting

      activities << activity if privacy.send(OPTS[activity.resource_type]) == 0
    end while activities.length < 7

    activities

  end
  

end

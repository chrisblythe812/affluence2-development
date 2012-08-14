class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  scope :previous, lambda { |p| {:conditions => ["id < ?", p.id], :limit => 1, :order => "id DESC"} }
  scope :next, lambda { |p| {:conditions => ["id > ?", p.id], :limit => 1, :order => "id"} }


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


def self.all_by_privacy_setting(current_user, last_activity = false)
    ids = []
    current_user.connections.each { |x| ids<<x.friend.id }

    activity = nil
    if last_activity
      activity = self.find(last_activity.to_i)
    end
 
    activities = []
    begin
      activity = activity ? self.previous(activity).first : self.last
      break unless activity
      next if activity.resource.nil?
 
      privacy = activity.user.profile.privacy_setting

      if activity.resource_type == 'Profile'
        #activities << activity
      else
        if current_user == activity.user
          activities << activity 
        elsif (privacy.send(PrivacySetting::OPTS[activity.resource_type]) == 0)
          activities << activity 
        elsif (privacy.send(PrivacySetting::OPTS[activity.resource_type]) == 1)
          if ids.include?(activity.user_id)
            activities << activity
          end
        end
      end
   
    end while activities.length < 7

    activities

  end


  def self.create_user_event(user, event)
    create(:user_id => user.id,
           :body => " has registered for the ",
           :resource_type => 'Event',
           :resource_id => event.id)

  end


  def self.create_user_offer(user, offer)
    create(:user_id => user.id,
           :body => " has activated ",
           :resource_type => 'Offer',
           :resource_id => offer.id)

  end

  def self.create_user_concierge(user,concierge)
    create(:user_id => user.id,
           :body => " has utilized service",
           :resource_type => 'concierge',
           :resource_id => concierge.id)
  end


end

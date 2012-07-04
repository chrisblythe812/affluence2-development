class NotificationSetting < ActiveRecord::Base
  belongs_to :profile


  attr_accessible :newsletter, :events, :offers, :messages,
                  :event_reminders, :site_news


  #TODO used with cancan. See Ability model
  #  def attribute_viewable?(attr, current_user)
  #    return true if current_user == self.profile.user
  #
  #    level = self.send(attr)
  #    case level
  #    when nil, FRIENDS # default
  #      current_user.friends.include? self.profile.user
  #    when FRIENDS_OF_FRIENDS
  #      current_user.friends.include?(self.profile.user) # ||
  #               current_user.friends_of_friends.include?(self.profile.user)
  #    when EVERYONE
  #      true
  #    end
  #  end
end

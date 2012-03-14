class PrivacySetting < ActiveRecord::Base
  belongs_to :profile

  EVERYONE = 0
  CONTACTS_ONLY = 1
  NOBODY = 2

  PRIVACY_OPTS = [
    ["Everyone", EVERYONE],
    ["Contacts Only", CONTACTS_ONLY],
    ["Nobody", NOBODY]
  ]

  attr_accessible :events, :offers, :concierge, :photos,
    :invitations, :new_contact  

   
  validates_inclusion_of(accessible_attributes.to_a, :in => PRIVACY_OPTS.map {|p| p.last}, :allow_nil => true)


  def set_to_default_privacy
    self.tap do
      PrivacySetting.accessible_attributes.each {|p|  self.send("#{p}=", EVERYONE) }
      self.save
    end
  end
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

# -*- encoding : utf-8 -*-

#
#  == Define abilities for cancan
#
#  if  role admin
#    allow everything
#  else
#    if logged in
#      cancan methods for a logged in user
#      cancan methods for special roles
#    else
#      cancan for anyone (public)
#    end
#  end
#  
class Ability

  include CanCan::Ability
  def initialize(user)

    if user.admin?
      can :manage, :all
    end

    if user.operator?
      puts "operator"
      can :manage, :conversation
    end

    if user.free?
      cannot :all, :conversation
      cannot :all, :photo_stream
      cannot :all, :concierge
    end

    if user.free_vetted?
      cannot :all, :photo_stream
      can :all, :conversation
      cannot :all, :concierge
    end

    if (user.paid? || user.paid_vetted?)
      can :all, :conversation
      can :all, :photo_stream
      can :all, :concierge
    end

  end # initialize

end # class
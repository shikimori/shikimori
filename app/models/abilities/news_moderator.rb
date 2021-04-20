class Abilities::NewsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, Topics::NewsTopic
    can :promote, Topic
  end
end

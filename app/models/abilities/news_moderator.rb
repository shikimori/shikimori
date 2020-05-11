class Abilities::NewsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, Topics::NewsTopic
  end
end

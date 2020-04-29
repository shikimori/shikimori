class Abilities::NewsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :moderate, Topic
  end
end

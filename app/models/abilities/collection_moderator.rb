class Abilities::CollectionModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, Collection
    can :manage, CollectionRole
  end
end

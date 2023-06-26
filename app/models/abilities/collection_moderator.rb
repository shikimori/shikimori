class Abilities::CollectionModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    roles_abilities

    can :manage, Collection
    can :manage, CollectionRole
  end

  def roles_abilities
    can %i[
      manage_not_trusted_collections_author_role
    ], User
  end
end

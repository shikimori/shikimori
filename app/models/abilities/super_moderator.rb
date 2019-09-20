class Abilities::SuperModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can %i[
      manage_forum_moderator_role
      manage_review_moderator_role
      manage_collection_moderator_role
      manage_version_moderator_role
      manage_trusted_version_changer_role
      manage_not_trusted_version_changer_role
      manage_trusted_fansub_changer_role
      manage_retired_moderator_role
      manage_not_trusted_abuse_reporter_role
      manage_cheat_bot_role
    ], User

    can :destroy, Ban
  end
end

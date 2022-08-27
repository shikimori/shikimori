class Abilities::SuperModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    roles_abilities

    can :manage, Ban
    can :access_list, User

    can %i[merge destroy], Anime
    can %i[merge destroy], Manga
    can %i[merge destroy], Character
    can %i[merge destroy], Person

    can :refresh_stats, [Anime, Manga]

    clubs_abilities
    genres_studios_publishers_abilities
  end

  def roles_abilities # rubocop:disable MethodLength
    can %i[
      manage_forum_moderator_role
      manage_version_names_moderator_role
      manage_version_texts_moderator_role
      manage_version_moderator_role
      manage_version_fansub_moderator_role
      manage_trusted_version_changer_role
      manage_trusted_newsmaker_role
      manage_not_trusted_version_changer_role
      manage_not_trusted_names_changer_role
      manage_not_trusted_texts_changer_role
      manage_not_trusted_fansub_changer_role
      manage_trusted_fansub_changer_role
      manage_retired_moderator_role

      manage_censored_avatar_role
      manage_censored_profile_role
      manage_censored_nickname_role
      manage_cheat_bot_role
      manage_ignored_in_achievement_statistics_role
    ], User
  end

  def clubs_abilities
    can :manage, Club
    can :manage, ClubPage
    can :manage, ClubImage
  end

  def genres_studios_publishers_abilities
    can :update, Genre
    can :update, Studio
    can :update, Publisher
  end
end

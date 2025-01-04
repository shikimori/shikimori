class Abilities::SuperModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user # rubocop:disable Metrics/MethodLength
    roles_abilities

    can :manage, Ban
    can %i[access_list mass_ban], User
    can :reset_email, User do |user|
      !user.staff?
    end

    can %i[dangerous_action destroy], Anime
    can %i[dangerous_action destroy], Manga
    can %i[dangerous_action destroy], Character
    can %i[dangerous_action destroy], Person

    can :refresh_stats, [Anime, Manga]

    can :access_changelog, ApplicationRecord

    poster_abilities
    comment_abilities
    clubs_abilities

    can :search_user_id, UserImage
    can :restart, Shikimori
  end

  def roles_abilities # rubocop:disable MethodLength
    can %i[
      manage_forum_moderator_role

      manage_version_names_moderator_role
      manage_version_texts_moderator_role
      manage_version_moderator_role
      manage_version_fansub_moderator_role
      manage_version_videos_moderator_role
      manage_version_images_moderator_role
      manage_version_links_moderator_role

      manage_trusted_version_changer_role
      manage_trusted_episodes_changer_role
      manage_trusted_newsmaker_role
      manage_not_trusted_version_changer_role
      manage_not_trusted_names_changer_role
      manage_not_trusted_texts_changer_role
      manage_not_trusted_fansub_changer_role
      manage_not_trusted_videos_changer_role
      manage_not_trusted_images_changer_role
      manage_not_trusted_links_changer_role

      manage_trusted_fansub_changer_role
      manage_retired_moderator_role
      manage_genre_moderator_role

      manage_not_trusted_collections_author_role

      manage_censored_avatar_role
      manage_censored_profile_role
      manage_censored_nickname_role
      manage_cheat_bot_role
      manage_ignored_in_achievement_statistics_role
    ], User
  end

  def poster_abilities
    can %i[read accept reject censore cancel], Poster
  end

  def comment_abilities
    can :read, Comment
  end

  def clubs_abilities
    can :manage, Club
    can :manage, ClubPage
    can :manage, ClubImage
  end
end

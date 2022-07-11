class Abilities::VersionModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = %w[
    image
    desynced
  ]

  NOT_MANAGED_FIELDS = Abilities::VersionTextsModerator::MANAGED_FIELDS +
    Abilities::VersionNamesModerator::MANAGED_FIELDS +
    Abilities::VersionFansubModerator::MANAGED_FIELDS - MANAGED_FIELDS

  MANAGED_MODELS = Abilities::VersionTextsModerator::MANAGED_MODELS

  def initialize user # rubocop:disable MethodLength, AbcSize
    can :increment_episode, Anime
    can :rollback_episode, Anime
    can :upload_episode, Anime

    can :sync, [Anime, Manga, Person, Character]

    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) &&
        version.item_diff && ((
          (version.item_diff.keys & NOT_MANAGED_FIELDS).none? ||
          MANAGED_MODELS.exclude?(version.item_type)
        ) || (
          (version.item_diff.keys & MANAGED_FIELDS).any? &&
          MANAGED_MODELS.include?(version.item_type)
        ))
    end
    cannot :destroy, Version do |version|
      version.user_id != user.id
    end

    can %i[filter autocomplete_user autocomplete_moderator], Version
  end
end

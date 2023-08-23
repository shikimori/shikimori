class Abilities::VersionModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = %w[
    desynced
  ]

  NOT_MANAGED_FIELDS = (Types::User::VERSION_ROLES - %i[version_moderator])
    .flat_map { |v| "Abilities::#{v.to_s.classify}".constantize::MANAGED_FIELDS }
    .uniq - MANAGED_FIELDS

  MANAGED_FIELDS_MODELS = Abilities::VersionTextsModerator::MANAGED_FIELDS_MODELS

  def initialize user
    can %i[
      upload_episode
      increment_episode
      rollback_episode
    ], Anime
    can %i[sync arbitrary_sync], [Anime, Manga, Person, Character]

    version_abilities user
  end

private

  def version_abilities user
    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) &&
        version.item_diff && (
          (version.item_diff.keys & NOT_MANAGED_FIELDS).none? ||
          MANAGED_FIELDS_MODELS.exclude?(version.item_type)
        )
    end
    cannot :destroy, Version do |version|
      version.user_id != user.id
    end

    can %i[filter autocomplete_user autocomplete_moderator], Version
  end
end

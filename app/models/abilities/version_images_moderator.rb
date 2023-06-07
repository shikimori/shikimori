class Abilities::VersionImagesModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = %w[
    image
    poster
    screenshots
    desynced
  ]
  MANAGED_FIELDS_MODELS = [Anime.name]
  MANAGED_MODELS = [Poster.name]

  def initialize user # rubocop:disable Metrics/MethodLength
    can :sync, [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end

    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) && (
        (
          version.item_diff &&
          (version.item_diff.keys & MANAGED_FIELDS).any? &&
          MANAGED_FIELDS_MODELS.include?(version.item_type)
        ) || MANAGED_MODELS.include?(version.item_type)
      )
    end

    cannot :destroy, Version do |version|
      version.user_id != user.id
    end

    can %i[filter autocomplete_user autocomplete_moderator], Version
  end
end

class Abilities::VersionVideosModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = %w[
    videos
  ]
  MANAGED_FIELDS_MODELS = [Anime.name]
  MANAGED_MODELS = [Video.name]

  def initialize user
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

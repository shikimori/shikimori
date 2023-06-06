class Abilities::VersionVideosModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = %w[
    videos
  ]
  MANAGED_MODELS = [Anime.name]

  def initialize user
    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) &&
        version.item_diff &&
        (version.item_diff.keys - MANAGED_FIELDS).none?
    end

    cannot :destroy, Version do |version|
      version.user_id != user.id
    end

    can %i[filter autocomplete_user autocomplete_moderator], Version
  end
end

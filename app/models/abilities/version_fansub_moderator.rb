class Abilities::VersionFansubModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = %w[fandubbers fansubbers]

  def initialize _user
    can :increment_episode, Anime
    can :rollback_episode, Anime
    can :upload_episode, Anime

    can :sync, [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end

    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) &&
        version.item_diff &&
        (version.item_diff.keys - MANAGED_FIELDS).none?
    end

    can %i[manage_not_trusted_fansub_changer_role], User

    can %i[filter autocomplete_user autocomplete_moderator], Version
  end
end

class Abilities::TrustedEpisodesChanger
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = %w[
    episodes_aired
  ]
  MANAGED_MODELS = %w[Anime]

  def initialize _user
    can :increment_episode, Anime
    can :rollback_episode, Anime
    # can %i[create], Version do |version|
    #   version.user_id == user.id &&
    #     !version.is_a?(Versions::RoleVersion)
    # end

    # can :restricted_update, Version

    can :auto_accept, Version do |version|
      !version.is_a?(Versions::RoleVersion) &&
        version.item_diff &&
        (version.item_diff.keys & MANAGED_FIELDS).any? &&
        MANAGED_MODELS.include?(version.item_type)
    end
  end
end

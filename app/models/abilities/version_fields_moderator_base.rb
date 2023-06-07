class Abilities::VersionFieldsModeratorBase
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = []
  MANAGED_FIELDS_MODELS = []
  MANAGED_MODELS = []

  def initialize user
    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) && (
        (
          version.item_diff &&
          (version.item_diff.keys - self.class::MANAGED_FIELDS).none? &&
          self.class::MANAGED_FIELDS_MODELS.include?(version.item_type)
        ) || self.class::MANAGED_MODELS.include?(version.item_type)
      )
    end

    cannot :destroy, Version do |version|
      version.user_id != user.id
    end

    can %i[filter autocomplete_user autocomplete_moderator], Version
  end
end

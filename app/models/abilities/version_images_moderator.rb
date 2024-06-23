class Abilities::VersionImagesModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[
    image
    poster
    screenshots
    desynced
  ]
  MANAGED_FIELDS_MODELS = Abilities::VersionTextsModerator::MANAGED_FIELDS_MODELS
  MANAGED_MODELS = [Poster.name]
  IGNORED_FIELDS = %w[action]

  def initialize _user
    super

    can %i[manage_not_trusted_images_changer_role], User
    can %i[read], Poster
    can_sync
  end
end

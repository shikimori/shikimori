class Abilities::VersionFansubModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[fandubbers fansubbers]
  MANAGED_FIELDS_MODELS = [Anime.name]

  def initialize _user
    super

    can %i[manage_not_trusted_fansub_changer_role], User
    can_sync
  end
end

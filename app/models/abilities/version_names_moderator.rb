class Abilities::VersionNamesModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[
    name
    russian
    english
    license_name_ru
    synonyms
    japanese
    desynced
  ]
  MANAGED_FIELDS_MODELS = Abilities::VersionTextsModerator::MANAGED_FIELDS_MODELS

  def initialize _user
    super

    can %i[manage_not_trusted_names_changer_role], User
    can_sync
  end
end

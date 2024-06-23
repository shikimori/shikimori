class Abilities::VersionTextsModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[
    description_ru
    description_en
    desynced
  ]
  MANAGED_FIELDS_MODELS = [
    Anime.name,
    Manga.name,
    Ranobe.name,
    Character.name,
    Person.name
  ]
  IGNORED_FIELDS = %w[source]

  def initialize _user
    super

    can %i[manage_not_trusted_texts_changer_role], User
    can_sync
  end
end

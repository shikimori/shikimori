class Abilities::VersionTextsModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[
    description_ru
    description_en
    desynced
    source
  ]
  MANAGED_FIELDS_MODELS = [
    Anime.name,
    Manga.name,
    Ranobe.name,
    Character.name,
    Person.name
  ]

  def initialize _user
    super

    can :sync, [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end
    can %i[manage_not_trusted_texts_changer_role], User
  end
end

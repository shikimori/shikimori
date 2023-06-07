class Abilities::VersionFansubModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[fandubbers fansubbers]
  MANAGED_FIELDS_MODELS = [Anime.name]

  def initialize _user
    super

    can :sync, [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end
    can %i[manage_not_trusted_fansub_changer_role], User
  end
end

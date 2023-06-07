class Abilities::VersionLinksModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[
    external_links
    desynced
  ]
  MANAGED_FIELDS_MODELS = [Anime.name, Manga.name]
end

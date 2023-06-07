class Abilities::VersionVideosModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[
    videos
  ]
  MANAGED_FIELDS_MODELS = [Anime.name]
  MANAGED_MODELS = [Video.name]
end

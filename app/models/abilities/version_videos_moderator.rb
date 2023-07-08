class Abilities::VersionVideosModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[
    videos
  ]
  MANAGED_FIELDS_MODELS = [Anime.name]
  MANAGED_MODELS = [Video.name]
  IGNORED_FIELDS = %w[action]

  def initialize _user
    super

    can %i[manage_not_trusted_videos_changer_role], User
  end
end

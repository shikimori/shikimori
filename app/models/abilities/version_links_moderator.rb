class Abilities::VersionLinksModerator < Abilities::VersionFieldsModeratorBase
  MANAGED_FIELDS = %w[
    external_links
    desynced
  ]
  MANAGED_FIELDS_MODELS = [Anime.name, Manga.name]

  def initialize _user
    super

    can %i[manage_not_trusted_links_changer_role], User
    can_sync
  end
end

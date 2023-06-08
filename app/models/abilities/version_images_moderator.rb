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

    can :sync, [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end
  end
end

class Abilities::VersionTextsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = %w[
    name
    russian
    english
    license_name_ru
    synonyms
    description_ru
    description_en
    japanese
  ]
  MANAGED_MODELS = [Anime.name, Manga.name, Ranobe.name, Character.name, Person.name]

  def initialize _user
    can :increment_episode, Anime
    can :rollback_episode, Anime
    can :upload_episode, Anime

    can :sync, [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end

    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) &&
        version.item_diff &&
        (version.item_diff.keys & MANAGED_FIELDS).any? &&
        MANAGED_MODELS.include?(version.item_type)
    end
  end
end

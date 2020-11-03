class Abilities::VersionTextsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MANAGED_FIELDS = %w[
    description_ru
    description_en
  ]
  MANAGED_MODELS = [
    Anime.name,
    Manga.name,
    Ranobe.name,
    Character.name,
    Person.name
  ]

  def initialize user
    can :sync, [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end

    can :manage, Version do |version|
      !version.is_a?(Versions::RoleVersion) &&
        version.item_diff &&
        (version.item_diff.keys & MANAGED_FIELDS).any? &&
        MANAGED_MODELS.include?(version.item_type)
    end
    cannot :destroy, Version do |version|
      version.user_id != user.id
    end

    can %i[manage_not_trusted_texts_changer_role], User

    can %i[filter autocomplete_user autocomplete_moderator], Version
  end
end

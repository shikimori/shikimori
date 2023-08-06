class Types::MangaType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::DescriptionFields

  field :license_name_ru, String
  field :english, String
  field :franchise, String, description: 'Franchise name'
  field :kind, Types::Enums::Manga::KindEnum
  field :score, Float
  field :status, Types::Enums::StatusEnum
  field :volumes, Integer
  field :chapters, Integer

  field :aired_on, Types::Scalars::IncompleteDate
  field :released_on, Types::Scalars::IncompleteDate

  field :licensors, [String]

  field :is_censored, Boolean
  def is_censored # rubocop:disable Naming/PredicateName
    object.censored?
  end

  field :genres, [Types::GenreType]
  field :publishers, [Types::PublisherType]

  field :external_links, [Types::ExternalLinkType], complexity: 10
  def external_links
    decorated_object.menu_external_links
  end

  field :character_roles, [Types::CharacterRoleType], complexity: 10
  def character_roles
    object.person_roles.select(&:character_id)
  end

  field :person_roles, [Types::PersonRoleType], complexity: 10
  def person_roles
    object.person_roles.select(&:person_id)
  end

  field :user_rate, Types::UserRateType, complexity: 50
  def user_rate
    context[:manga_user_rates] ?
      context[:manga_user_rates][object.id] :
      decorated_object.current_rate
  end
end

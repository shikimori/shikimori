class Types::AnimeType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::DescriptionFields

  field :license_name_ru, String
  field :english, String
  field :franchise, String, description: 'Franchise name'
  field :kind, Types::Enums::Anime::KindEnum
  field :rating, Types::Enums::Anime::RatingEnum
  field :score, Float
  field :status, Types::Enums::StatusEnum
  field :episodes, Integer
  field :episodes_aired, Integer
  field :duration, Integer, description: 'Duration in minutes'

  field :season, String

  field :aired_on, Types::Scalars::IncompleteDate
  field :released_on, Types::Scalars::IncompleteDate

  field :next_episode_at, GraphQL::Types::ISO8601DateTime

  field :fansubbers, [String]
  field :fandubbers, [String]
  field :licensors, [String]

  field :is_censored, Boolean
  def is_censored # rubocop:disable Naming/PredicateName
    object.censored?
  end

  field :genres, [Types::GenreType]
  field :studios, [Types::StudioType]

  field :videos, [Types::VideoType], complexity: 10
  field :screenshots, [Types::ScreenshotType], complexity: 10

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
    decorated_object.current_rate
  end
end

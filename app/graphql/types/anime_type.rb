class Types::AnimeType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::DescriptionFields

  field :license_name_ru, String
  field :english, String
  field :franchise, String, description: 'Franchise name'
  field :kind, Types::Enums::Anime::KindEnum
  field :rating, Types::Enums::Anime::RatingEnum
  field :score, Float
  field :status, Types::Enums::Anime::StatusEnum
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
end

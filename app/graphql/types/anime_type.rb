class Types::AnimeType < Types::BaseObject
  field :id, ID
  field :name, String
  field :russian, String
  field :license_name_ru, String
  field :english, String
  field :japanese, String
  field :synonyms, [String]
  field :franchise, String, description: 'Franchise name'
  field :kind, Types::Enums::Anime::KindEnum
  field :score, Float
  field :status, Types::Enums::Anime::StatusEnum
  field :episodes, Integer
  field :episodes_aired, Integer
  field :duration, Integer, description: 'Duration in minutes'

  field :url, String
  def url
    UrlGenerator.instance.anime_url object
  end

  field :season, String

  field :aired_on, GraphQL::Types::ISO8601Date
  def aired_on
    object.aired_on.date
  end

  field :released_on, GraphQL::Types::ISO8601Date
  def released_on
    object.released_on.date
  end

  field :created_at, GraphQL::Types::ISO8601DateTime
  field :updated_at, GraphQL::Types::ISO8601DateTime
  field :next_episode_at, GraphQL::Types::ISO8601DateTime

  field :fansubbers, [String]
  field :fandubbers, [String]
  field :licensors, [String]

  field :is_censored, Boolean
  def is_censored # rubocop:disable Naming/PredicateName
    object.censored?
  end

  field :description, String
  def description
    decorated_object.description.text
  end
  field :description_html, String
  delegate :description_html, to: :decorated_object
  field :description_source, String
  def description_source
    decorated_object.description.source
  end

  field :poster, Types::PosterType
  field :genres, [Types::GenreType]
  field :studios, [Types::StudioType]

private

  def decorated_object
    @decorated_object ||= object.decorate
  end
end

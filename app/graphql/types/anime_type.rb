class Types::AnimeType < Types::BaseObject
  field :id, ID
  field :name, String
  field :russian, String
  field :kind, Types::Enums::Anime::KindEnum
  field :score, Float
  field :status, Types::Enums::Anime::StatusEnum
  field :episodes, Integer
  field :episodes_aired, Integer

  field :aired_on, GraphQL::Types::ISO8601Date
  def aired_on
    object.aired_on.date
  end

  field :released_on, GraphQL::Types::ISO8601Date
  def released_on
    object.released_on.date
  end

  field :url, String
  def url
    UrlGenerator.instance.anime_url object
  end

  field :poster, Types::PosterType
  field :genres, [Types::GenreType]
end

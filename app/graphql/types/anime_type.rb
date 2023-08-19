class Types::AnimeType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::AniMangaFields
  include Types::Concerns::DescriptionFields

  field :kind, Types::Enums::Anime::KindEnum
  field :rating, Types::Enums::Anime::RatingEnum
  field :episodes, Integer
  field :episodes_aired, Integer
  field :duration, Integer, description: 'Duration in minutes'

  field :season, String

  field :next_episode_at, GraphQL::Types::ISO8601DateTime

  field :fansubbers, [String]
  field :fandubbers, [String]

  field :studios, [Types::StudioType]

  field :videos, [Types::VideoType], complexity: 10
  field :screenshots, [Types::ScreenshotType], complexity: 10

  field :user_rate, Types::UserRateType, complexity: 50
  def user_rate
    context[:anime_user_rates] ?
      context[:anime_user_rates][object.id] :
      decorated_object.current_rate
  end
end

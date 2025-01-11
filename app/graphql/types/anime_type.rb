class Types::AnimeType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::AniMangaFields
  include Types::Concerns::DescriptionFields

  field :kind, Types::Enums::Anime::KindEnum
  field :status, Types::Enums::Anime::StatusEnum

  field :rating, Types::Enums::Anime::RatingEnum
  field :origin, Types::Enums::Anime::OriginEnum
  field :episodes, Integer, null: false
  field :episodes_aired, Integer, null: false
  field :duration, Integer, description: 'Duration in minutes'

  field :season, String

  field :next_episode_at, GraphQL::Types::ISO8601DateTime
  def next_episode_at
    object.next_episode_at || decorated_object.next_broadcast_at
  end

  field :fansubbers, [String], null: false
  field :fandubbers, [String], null: false

  field :studios, [Types::StudioType], null: false

  field :videos, [Types::VideoType], null: false, complexity: 10
  field :screenshots, [Types::ScreenshotType], null: false, complexity: 10

  field :user_rate, Types::UserRateType, complexity: 50
  def user_rate
    context[:anime_user_rates] ?
      context[:anime_user_rates][object.id] :
      decorated_object.current_rate
  end

  field :chronology, [Types::AnimeType], complexity: 50

  def opengraph_image_url
    "http://cdn.anime-recommend.ru/previews/#{object.id}.jpg"
  end
end

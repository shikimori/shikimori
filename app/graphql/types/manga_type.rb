class Types::MangaType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::AniMangaFields
  include Types::Concerns::DescriptionFields

  field :kind, Types::Enums::Manga::KindEnum
  field :status, Types::Enums::Manga::StatusEnum

  field :volumes, Integer, null: false
  field :chapters, Integer, null: false

  field :publishers, [Types::PublisherType], null: false

  field :user_rate, Types::UserRateType, complexity: 50
  def user_rate
    context[:manga_user_rates] ?
      context[:manga_user_rates][object.id] :
      decorated_object.current_rate
  end

  field :chronology, [Types::MangaType], complexity: 50

  def opengraph_image_url
    "http://cdn.anime-recommend.ru/previews/manga/#{object.id}.jpg"
  end
end

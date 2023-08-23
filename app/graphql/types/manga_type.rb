class Types::MangaType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::AniMangaFields
  include Types::Concerns::DescriptionFields

  field :kind, Types::Enums::Manga::KindEnum

  field :volumes, Integer
  field :chapters, Integer

  field :publishers, [Types::PublisherType]

  field :user_rate, Types::UserRateType, complexity: 50
  def user_rate
    context[:manga_user_rates] ?
      context[:manga_user_rates][object.id] :
      decorated_object.current_rate
  end
end

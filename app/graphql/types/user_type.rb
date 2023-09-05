class Types::UserType < Types::BaseObject
  field :id, ID
  field :nickname, String
  field :url, String
  def url
    UrlGenerator.instance.profile_url(object)
  end

  field :avatar_url, String
  def avatar_url
    object.avatar_url 160, context[:current_user]&.id == object.id
  end

  field :last_online_at, GraphQL::Types::ISO8601DateTime
  def last_online_at
    object[:last_online_at]
  end

  field :anime, Types::AnimeType
  field :manga, Types::MangaType
end

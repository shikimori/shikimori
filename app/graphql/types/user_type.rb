class Types::UserType < Types::BaseObject
  field :id, ID, null: false
  field :nickname, String, null: false
  field :url, String, null: false
  def url
    UrlGenerator.instance.profile_url(object)
  end

  field :avatar_url, String, null: false
  def avatar_url
    object.avatar_url 160, context[:current_user]&.id == object.id
  end

  field :last_online_at, GraphQL::Types::ISO8601DateTime, null: false
  def last_online_at
    object[:last_online_at]
  end
end

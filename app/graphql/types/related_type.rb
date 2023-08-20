class Types::RelatedType < Types::BaseObject
  field :id, GraphQL::Types::BigInt
  field :anime, Types::AnimeType
  field :manga, Types::MangaType

  field :relation_en, String
  def relation_en
    object.relation
  end

  field :relation_ru, String
  def relation_ru
    I18n.t "relation.#{object.relation}"
  end
end

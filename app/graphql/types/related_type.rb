class Types::RelatedType < Types::BaseObject
  field :id, ID, null: false
  field :anime, Types::AnimeType
  field :manga, Types::MangaType

  field :relation_ru, String, null: false
  def relation_ru
    I18n.t "relation.#{object.relation}"
  end

  field :relation_en, String, null: false
  def relation_en
    object.relation
  end
end

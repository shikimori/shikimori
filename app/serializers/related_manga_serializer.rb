class RelatedMangaSerializer < ActiveModel::Serializer
  attributes :relation, :relation_russian
  has_one :anime
  has_one :manga

  def relation_russian
    object.relation_kind_text
  end
end

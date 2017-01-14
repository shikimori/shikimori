class RelatedAnimeSerializer < ActiveModel::Serializer
  attributes :relation, :relation_russian
  has_one :anime
  has_one :manga

  def relation_russian
    I18n.t "relation.#{object.relation}"
  end
end

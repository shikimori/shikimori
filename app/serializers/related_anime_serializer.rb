class RelatedAnimeSerializer < ActiveModel::Serializer
  attributes :relation, :relation_russian
  has_one :anime, :manga

  def relation_russian
    I18n.t "relation.#{object.relation}"
  end
end

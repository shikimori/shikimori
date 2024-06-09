class RelatedAnimeSerializer < ActiveModel::Serializer
  attributes :relation, :relation_russian
  has_one :anime
  has_one :manga

  def relation
    I18n.t "enumerize.related_anime.relation_kind.#{object.relation_kind}",
      locale: :en
  end

  def relation_russian
    I18n.t "enumerize.related_anime.relation_kind.#{object.relation_kind}",
      locale: :ru
  end
end

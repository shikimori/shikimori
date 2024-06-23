class Types::RelatedType < Types::BaseObject
  field :id, ID, null: false
  field :anime, Types::AnimeType
  field :manga, Types::MangaType

  field :relation_kind, Types::Enums::RelationKindEnum, null: false
  field :relation_text, String, null: false
  def relation_text
    object.relation_kind_text
  end

  field :relation_ru, String,
    null: false,
    deprecation_reason: 'use relation_kind/relation_text instead. This field will be deleted after 2025-01-01'
  def relation_ru
    I18n.t("enumerize.related_anime.relation_kind.#{object.relation_kind}", locale: :ru)
  end

  field :relation_en, String,
    null: false,
    deprecation_reason: 'use relation_kind/relation_text instead. This field will be deleted after 2025-01-01'
  def relation_en
    I18n.t("enumerize.related_anime.relation_kind.#{object.relation_kind}", locale: :en)
  end
end

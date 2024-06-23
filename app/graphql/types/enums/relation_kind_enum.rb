class Types::Enums::RelationKindEnum < GraphQL::Schema::Enum
  graphql_name 'RelationKindEnum'

  Types::RelatedAniManga::RelationKind.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.related_anime.relation_kind.#{key}", locale: :en)
  end
end

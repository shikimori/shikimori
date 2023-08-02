class Types::Enums::Video::KindEnum < GraphQL::Schema::Enum
  graphql_name 'VideoKindEnum'

  Types::Video::Kind.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.video.kind.#{key}", locale: :en)
  end
end

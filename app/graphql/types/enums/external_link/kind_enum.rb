class Types::Enums::ExternalLink::KindEnum < GraphQL::Schema::Enum
  graphql_name 'ExternalLinkKindEnum'

  # Types::ExternalLink::Kind.values - Types::ExternalLink::WATCH_ONLINE_KINDS
  Types::ExternalLink::Kind.values.each do |key| # rubocop:disable Style/HashEachMethods
    value(
      key,
      I18n.t("enumerize.external_link.kind.#{key}", locale: :en, default: key.to_s.capitalize)
    )
  end
end

class Types::Enums::Contest::MemberTypeEnum < GraphQL::Schema::Enum
  graphql_name 'ContestMemberTypeEnum'

  Types::Contest::MemberType.values.each do |key| # rubocop:disable Style/HashEachMethods
    value key, I18n.t("enumerize.contest.member_type.#{key}", locale: :en)
  end
end

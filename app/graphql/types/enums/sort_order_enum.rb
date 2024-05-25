class Types::Enums::SortOrderEnum < GraphQL::Schema::Enum
  graphql_name 'SortOrderEnum'

  value :asc, 'Sort in ascending order'
  value :desc, 'Sort in descending order'
end

module Types
  class QueryType < GraphQL::Schema::Object
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    # include GraphQL::Types::Relay::HasNodeField
    # include GraphQL::Types::Relay::HasNodesField
    field :animes, resolver: Queries::AnimesQuery
    field :mangas, resolver: Queries::MangasQuery
    field :characters, resolver: Queries::CharactersQuery
    field :people, resolver: Queries::PeopleQuery
  end
end

class Types::TopicType < Types::BaseObject
  field :id, GraphQL::Types::ID
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end

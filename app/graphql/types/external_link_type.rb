class Types::ExternalLinkType < Types::BaseObject
  field :id, ID, null: false

  field :kind, Types::Enums::ExternalLink::KindEnum, null: false
  field :url, String, null: false

  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
end

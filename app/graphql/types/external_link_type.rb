class Types::ExternalLinkType < Types::BaseObject
  field :id, ID, null: true # MAL external link has null field

  field :kind, Types::Enums::ExternalLink::KindEnum, null: false
  field :url, String, null: false

  field :created_at, GraphQL::Types::ISO8601DateTime, null: true # MAL external link has null field
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: true # MAL external link has null field
end

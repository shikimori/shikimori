class Types::ExternalLinkType < Types::BaseObject
  field :id, ID

  field :kind, Types::Enums::ExternalLink::KindEnum
  field :url, String

  field :created_at, GraphQL::Types::ISO8601DateTime
  field :updated_at, GraphQL::Types::ISO8601DateTime
end

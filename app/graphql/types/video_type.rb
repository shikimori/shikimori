class Types::VideoType < Types::BaseObject
  field :id, GraphQL::Types::BigInt
  field :name, String
  field :url, String
  field :kind, Types::Enums::Video::KindEnum
end

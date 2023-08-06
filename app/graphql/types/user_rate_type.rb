class Types::UserRateType < Types::BaseObject
  field :id, GraphQL::Types::BigInt
  field :score, Integer
  field :status, Types::Enums::UserRate::StatusEnum
  field :rewatches, Integer
  field :episodes, Integer
  field :volumes, Integer
  field :chapters, Integer
  field :text, String

  field :created_at, GraphQL::Types::ISO8601DateTime
  field :updated_at, GraphQL::Types::ISO8601DateTime

  field :anime, Types::AnimeType, complexity: 100
  field :manga, Types::MangaType, complexity: 100
end

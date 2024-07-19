class Types::UserRateType < Types::BaseObject
  field :id, ID, null: false
  field :score, Integer, null: false
  field :status, Types::Enums::UserRate::StatusEnum, null: false
  field :rewatches, Integer, null: false
  field :episodes, Integer, null: false
  field :volumes, Integer, null: false
  field :chapters, Integer, null: false
  field :text, String

  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :anime, Types::AnimeType, complexity: 70
  field :manga, Types::MangaType, complexity: 70
end

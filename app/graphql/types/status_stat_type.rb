class Types::StatusStatType < Types::BaseObject
  field :status, Types::Enums::UserRate::StatusEnum, null: false
  field :count, Integer, null: false
end

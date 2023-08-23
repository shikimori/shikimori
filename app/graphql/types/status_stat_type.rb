class Types::StatusStatType < Types::BaseObject
  field :status, Types::Enums::UserRate::StatusEnum
  field :count, Integer
end

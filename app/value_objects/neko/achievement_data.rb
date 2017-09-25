class Neko::AchievementData < Dry::Struct
  constructor_type :strict

  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Types::Coercible::Int
  attribute :progress, Types::Coercible::Int
end

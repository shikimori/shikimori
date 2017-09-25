class Neko::AchievementData < Dry::Struct
  constructor_type :strict

  attribute :user_id, Types::Coercible::Int
  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Types::Coercible::Int
  attribute :progress, Types::Coercible::Int
end

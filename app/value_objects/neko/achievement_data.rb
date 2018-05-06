class Neko::AchievementData < Dry::Struct
  attribute :user_id, Types::Coercible::Integer
  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Types::Coercible::Integer
  attribute :progress, Types::Coercible::Integer
end

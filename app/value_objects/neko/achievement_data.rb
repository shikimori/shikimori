class Neko::AchievementData
  include ShallowAttributes

  attribute :user_id, Integer
  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Integer
  attribute :progress, Integer
end

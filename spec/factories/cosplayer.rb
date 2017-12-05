FactoryBot.define do
  factory :cosplayer do
    sequence(:name) { |n| "cosplayer_#{n}" }
  end
end

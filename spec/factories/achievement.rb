FactoryBot.define do
  factory :achievement do
    neko_id { Types::Achievement::NekoId[:test] }
    level { 1 }
    progress { 0 }
    user { seed :user }
  end
end

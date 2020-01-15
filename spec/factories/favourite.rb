FactoryBot.define do
  factory :favourite do
    linked { nil }
    user { seed :user }
    kind { Types::Favourite::Kind[:common] }
  end
end

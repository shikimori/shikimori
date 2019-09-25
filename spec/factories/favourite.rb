FactoryBot.define do
  factory :favourite do
    linked { nil }
    user { seed :user }
    kind { nil }
  end
end

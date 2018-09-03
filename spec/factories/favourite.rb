FactoryBot.define do
  factory :favourite do
    linked { nil }
    user { seed :user }
    kind { '' }
  end
end

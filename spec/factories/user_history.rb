FactoryBot.define do
  factory :user_history do
    user { seed :user }
    anime { nil }
    manga { nil }
    action { nil }
    value { nil }
  end
end

FactoryBot.define do
  factory :review_viewing do
    user { seed :user }
    viewed { nil }
  end
end

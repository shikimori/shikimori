FactoryBot.define do
  factory :comment_viewing do
    user { seed :user }
    viewed { nil }
  end
end

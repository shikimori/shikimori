FactoryBot.define do
  factory :topic_viewing do
    user { seed :user }
    viewed { nil }
  end
end

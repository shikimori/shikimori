FactoryBot.define do
  factory :summary_viewing do
    user { seed :user }
    viewed { nil }
  end
end

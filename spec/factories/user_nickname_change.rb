FactoryBot.define do
  factory :user_nickname_change do
    user { seed :user }
    sequence(:value) { |v| "changed #{v}" }
  end
end

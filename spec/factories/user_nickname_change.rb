FactoryGirl.define do
  factory :user_nickname_change do
    user
    sequence(:value) { |v| "changed #{v}" }
  end
end

FactoryBot.define do
  factory :user_token do
    user { seed :user }
    provider { 'facebook' }
    sequence(:uid) { |i| "uid_#{i}" }
  end
end

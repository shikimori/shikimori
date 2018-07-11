FactoryBot.define do
  factory :pg_cache do
    sequence(:key) { |n| "key-#{n}" }
    value 'test'
    expires_at nil
  end
end

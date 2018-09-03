FactoryBot.define do
  factory :pg_cache_data do
    sequence(:key) { |n| "key-#{n}" }
    value { 'test' }
    expires_at { nil }
  end
end

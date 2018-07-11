FactoryBot.define do
  factory :big_data_cache do
    sequence(:key) { |n| "key-#{n}" }
    value 'test'
    expires_at nil
  end
end

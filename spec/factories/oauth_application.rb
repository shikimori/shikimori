FactoryBot.define do
  factory :oauth_application do
    sequence(:name) { |n| "app-#{n}" }
    owner { seed :user }
    redirect_uri 'https://example.com'
  end
end

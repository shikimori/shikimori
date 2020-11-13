FactoryBot.define do
  factory :oauth_token, class: 'Doorkeeper::AccessToken' do
    sequence(:token) { |n| "tokenn}" }
  end
end

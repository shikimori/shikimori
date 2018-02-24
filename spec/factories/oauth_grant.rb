FactoryBot.define do
  factory :oauth_grant, class: 'Doorkeeper::AccessGrant' do
    expires_in 1.week
    redirect_uri Doorkeeper::NO_REDIRECT_URI
  end
end

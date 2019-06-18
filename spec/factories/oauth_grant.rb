FactoryBot.define do
  factory :oauth_grant, class: 'Doorkeeper::AccessGrant' do
    expires_in { 1.week }
    redirect_uri { Doorkeeper.configuration.native_redirect_uri }
  end
end

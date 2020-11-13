FactoryBot.define do
  factory :oauth_grant, class: 'Doorkeeper::AccessGrant' do
    resource_owner_id { 1 }
    expires_in { 1.week }
    redirect_uri { Doorkeeper.configuration.native_redirect_uri }
  end
end

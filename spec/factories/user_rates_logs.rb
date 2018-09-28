FactoryBot.define do
  factory :user_rate_log do
    user { seed :user }
    target { nil } 
    diff { {} }

    oauth_application { nil }
    user_agent { 'chrome' }
    ip { '127.0.0.1' }
  end
end

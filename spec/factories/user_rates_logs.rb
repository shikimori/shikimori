FactoryBot.define do
  factory :user_rates_log do
    user { seed :user }
    target { nil } 
    action { nil }
    value { nil }
    prior_value { nil }

    oauth_application { nil }
    user_agent { 'chrome' }
    ip { '127.0.0.1' }
  end
end

FactoryBot.define do
  factory :ban do
    user { seed :user }

    comment { seed :comment }
    topic { nil }
    review { nil }

    abuse_request { nil }
    moderator { nil }
    duration { 180 }
    reason { 'moderator comment' }

    trait :no_callbacks do
      after(:build) do |o|
        o.stub :ban_user
        o.stub :notify_user
        o.stub :mention_in_target
        o.stub :accept_abuse_request
        o.stub :set_user
      end
    end
  end
end

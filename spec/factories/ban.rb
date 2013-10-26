FactoryGirl.define do
  factory :ban do
    user nil
    comment nil
    moderator nil
    abuse_request nil
    duration 180
    reason 'reason'

    trait :no_callbacks do
      after(:build) do |o|
        o.stub :ban_user
        o.stub :notify_user
        o.stub :mention_in_comment
        o.stub :accept_abuse_request
        o.stub :set_user
      end
    end
  end
end

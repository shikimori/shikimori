FactoryGirl.define do
  factory :user do
    sequence(:nickname) { |n| "user_#{n}" }
    email { FactoryGirl.generate(:email) }
    password "123"
    last_online_at DateTime.now

    notifications User::DEFAULT_NOTIFICATIONS

    trait :admin do
      id User::Admins.first
    end

    trait :contests_moderator do
      id User::ContestsModerators.first
    end
  end
end

FactoryGirl.define do
  factory :user do
    sequence(:nickname) { |n| "user_#{n}" }
    email { FactoryGirl.generate(:email) }
    password "123"
    last_online_at DateTime.now

    notifications User::DEFAULT_NOTIFICATIONS

    trait :preferences do
      after :create do |user|
        FactoryGirl.create :user_preferences, user: user
      end
    end

    trait :user do
      sequence :id, 23456789
    end

    trait :guest do
      id User::GuestID
    end

    trait :admin do
      id User::Admins.last
    end

    trait :moderator do
      id User::Moderators.last
    end

    trait :contests_moderator do
      id User::ContestsModerators.last
    end

    trait :reviews_moderator do
      id User::ReviewsModerators.last
    end

    trait :video_moderator do
      id User::VideoModerators.last
    end

    trait :user_changes_moderator do
      id User::UserChangesModerators.last
    end

    trait :banhammer do
      id User::Banhammer_ID
    end

    trait :cosplayer do
      id User::Cosplayer_ID
    end

    trait :without_password do
      password nil

      after :build do |user|
        user.stub(:password_required?).and_return false
      end
    end
  end
end

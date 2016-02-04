FactoryGirl.define do
  factory :user do
    sequence(:nickname) { |n| "user_#{n}" }
    email { FactoryGirl.generate :email }
    password '123'
    last_online_at Time.zone.now

    can_vote_1 false
    can_vote_2 false
    can_vote_3 false

    notifications User::DEFAULT_NOTIFICATIONS

    after :build do |user|
      user.class.skip_callback :save, :before, :ensure_api_access_token
    end

    trait :user do
      sequence :id, 23456789
    end

    trait :guest do
      id User::GUEST_ID
    end

    trait :admin do
      id User::ADMINS.last
    end

    trait :moderator do
      id User::MODERATORS.last
    end

    trait :contests_moderator do
      id User::CONTEST_MODERATORS.last
    end

    trait :reviews_moderator do
      id User::REVIEWS_MODERATORS.last
    end

    trait :video_moderator do
      id User::VIDEO_MODERATORS.last
    end

    trait :versions_moderator do
      id User::VERSIONS_MODERATORS.last
    end

    trait :banhammer do
      id User::BANHAMMER_ID
    end

    trait :cosplayer do
      id User::COSPLAYER_ID
    end

    trait :trusted_video_uploader do
      id User::TRUSTED_VIDEO_UPLOADERS.last
    end

    trait :without_password do
      password nil

      after :build do |user|
        user.stub(:password_required?).and_return false
      end
    end

    trait :banned do
      read_only_at 1.year.from_now - 1.week
    end

    trait :forever_banned do
      read_only_at 1.year.from_now + 1.week
    end

    trait :day_registered do
      created_at 25.hours.ago
    end

    trait :with_avatar do
      avatar { File.new(Rails.root.join('spec', 'images', 'anime.jpg')) }
    end
  end
end

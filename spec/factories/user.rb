FactoryBot.define do
  factory :user do
    sequence(:nickname) { |n| "user_#{n}" }
    sequence(:email) { |n| "email#{n}@factory.com" }
    password { '123' }
    last_online_at { Time.zone.now }
    sign_in_count { 7 }

    can_vote_1 { false }
    can_vote_2 { false }
    can_vote_3 { false }

    about { '' }

    activity_at { nil }
    rate_at { nil }

    after :build do |model|
      stub_method model, :add_to_index
      stub_method model, :create_history_entry
      stub_method model, :assign_style
      stub_method model, :send_welcome_message
      stub_method model, :grab_avatar
    end

    trait :with_assign_style do
      after(:build) { |model| unstub_method model, :assign_style }
    end

    trait :user do
      sequence(:nickname) { |v| "user_user ##{v}" }
    end
    trait(:guest) { id { User::GUEST_ID } }

    trait :admin do
      id { User::MORR_ID }
      nickname { 'user_admin' }
      roles { %i[admin] }
    end
    trait :banhammer do
      id { User::BANHAMMER_ID }
      nickname { 'banhammer' }
      roles { %i[bot] }
    end
    trait :messanger do
      id { User::MESSANGER_ID }
      nickname { 'messanger' }
      roles { %i[bot] }
    end

    (Types::User::ROLES - %i[admin]).each do |role|
      trait(role) { roles { [role] } }
    end

    trait :api_video_uploader do
      day_registered
      sequence(:nickname) { |n| "api_video_uploader_#{n}" }
      roles { %i[api_video_uploader] }
    end

    trait :suspicious do
      sign_in_count { 5 }
    end

    trait :without_password do
      password { nil }

      after :build do |user|
        user.stub(:password_required?).and_return false
      end
    end

    trait(:banned) { read_only_at { 1.year.from_now - 1.week } }
    trait(:forever_banned) { read_only_at { 1.year.from_now + 1.week } }

    trait(:day_registered) do
      sequence(:nickname) { |n| "day_registered_#{n}" }
      created_at { 25.hours.ago }
    end
    trait(:week_registered) do
      nickname { 'week_registered' }
      created_at { 8.days.ago }
    end

    trait :with_avatar do
      avatar { File.new "#{Rails.root}/spec/files/anime.jpg" }
    end

    factory :user_admin, traits: %i[admin]
    factory :user_messanger, traits: %i[messanger]
    factory :user_day_registered, traits: %i[day_registered]
    factory :user_week_registered, traits: %i[week_registered]
  end
end

FactoryBot.define do
  factory :user do
    sequence(:nickname) { |n| "user_#{n}" }
    sequence(:email) { |n| "email#{n}@factory.com" }
    password '123'
    last_online_at { Time.zone.now }
    sign_in_count 7

    can_vote_1 false
    can_vote_2 false
    can_vote_3 false

    notifications User::DEFAULT_NOTIFICATIONS

    locale 'ru'
    locale_from_host 'ru'

    after :build do |model|
      stub_method model, :create_history_entry
      stub_method model, :reset_api_access_token
      stub_method model, :assign_style
      stub_method model, :send_welcome_message
      stub_method model, :grab_avatar
    end

    trait :with_assign_style do
      after(:build) { |model| unstub_method model, :assign_style }
    end

    trait(:user) { sequence :id, 23_456_789 }
    trait(:guest) { id User::GUEST_ID }
    trait :banhammer do
      id User::BANHAMMER_ID
      roles %i[bot]
    end
    trait :cosplayer do
      id User::COSPLAYER_ID
      roles %i[bot]
    end

    Types::User::ROLES.each do |role|
      trait(role) { roles [role] }
    end

    trait :suspicious do
      sign_in_count 5
    end

    trait :without_password do
      password nil

      after :build do |user|
        user.stub(:password_required?).and_return false
      end
    end

    trait(:banned) { read_only_at { 1.year.from_now - 1.week } }
    trait(:forever_banned) { read_only_at { 1.year.from_now + 1.week } }
    trait(:day_registered) { created_at { 25.hours.ago } }
    trait(:week_registered) { created_at { 8.days.ago } }

    trait :with_avatar do
      avatar { File.new "#{Rails.root}/spec/files/anime.jpg" }
    end

    factory :cosplay_user, traits: [:cosplayer]
  end
end

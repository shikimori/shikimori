FactoryBot.define do
  factory :message do
    from { seed :user }
    to { seed :user }

    read { false }

    after :build do |model|
      stub_method model, :antispam_checks
      stub_method model, :check_spam_abuse
      stub_method model, :send_email
      stub_method model, :mark_replies_as_read
    end

    kind { MessageType::PRIVATE }
    body { 'test' }

    trait :private do
      kind { MessageType::PRIVATE }
    end

    trait :notification do
      kind { MessageType::NOTIFICATION }
    end

    trait :profile_commented do
      kind { MessageType::PROFILE_COMMENTED }
    end

    trait :news do
      kind { MessageType::SITE_NEWS }
    end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
    trait :with_check_spam_abuse do
      after(:build) { |model| unstub_method model, :check_spam_abuse }
    end
    trait :with_send_email do
      after(:build) { |model| unstub_method model, :send_email }
    end
    trait :with_mark_replies_as_read do
      after(:build) { |model| unstub_method model, :mark_replies_as_read }
    end
  end
end

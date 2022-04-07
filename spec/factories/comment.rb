FactoryBot.define do
  factory :comment do
    user { seed :user }
    commentable { seed :offtopic_topic }
    sequence(:body) { |n| "comment_body_#{n}" }
    is_offtopic { false }
    is_summary { false }

    after :build do |model|
      stub_method model, :antispam_checks
      stub_method model, :check_access
      stub_method model, :increment_comments
      stub_method model, :sync_comments
      stub_method model, :decrement_comments
      stub_method model, :release_the_banhammer!
      stub_method model, :touch_commentable
      stub_method model, :create_viewing
      stub_method model, :notify_quoted
    end

    trait :with_create_viewing do
      after(:build) { |model| unstub_method model, :create_viewing }
    end

    trait :skip_forbid_tags_change do
      after :build do |model|
        stub_method model, :forbid_tags_change
      end
    end

    trait :offtopic do
      is_offtopic { true }
      body { 'xx' }
    end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end

    trait :with_increment_comments do
      after(:build) { |model| unstub_method model, :increment_comments }
    end

    trait :with_sync_comments do
      after(:build) { |model| unstub_method model, :sync_comments }
    end

    trait :with_decrement_comments do
      after(:build) { |model| unstub_method model, :decrement_comments }
    end

    trait :with_banhammer do
      after(:build) { |model| unstub_method model, :release_the_banhammer! }
    end

    trait :with_touch_commentable do
      after(:build) { |model| unstub_method model, :touch_commentable }
    end

    trait :with_notify_quoted do
      after(:build) { |model| unstub_method model, :notify_quoted }
    end
  end
end

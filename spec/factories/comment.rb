FactoryBot.define do
  factory :comment do
    user { seed :user }
    commentable { seed :offtopic_topic }
    sequence(:body) { |n| "comment_body_#{n}" }
    is_offtopic false
    is_summary false

    after :build do |model|
      stub_method model, :check_antispam
      stub_method model, :check_access
      stub_method model, :increment_comments
      stub_method model, :creation_callbacks
      stub_method model, :release_the_banhammer!
      stub_method model, :touch_commentable
    end

    trait :with_create_viewing do
      after(:build) { |model| unstub_method model, :create_viewing }
    end

    trait :summary do
      is_summary true
      body 'x' * Comment::MIN_SUMMARY_SIZE
    end

    trait :offtopic do
      is_offtopic true
      body 'x' * Comment::MIN_SUMMARY_SIZE
    end

    trait :with_antispam do
      after(:build) { |comment| comment.unstub :check_antispam }
    end

    trait :with_counter_cache do
      after(:build) { |comment| comment.unstub :increment_comments }
    end

    trait :with_creation_callbacks do
      after(:build) { |comment| comment.unstub :creation_callbacks }
    end

    trait :with_banhammer do
      after(:build) { |comment| comment.unstub :release_the_banhammer! }
    end

    trait :with_touch_commentable do
      after(:build) { |comment| comment.unstub :touch_commentable }
    end

  end
end

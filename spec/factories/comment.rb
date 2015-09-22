FactoryGirl.define do
  factory :comment do
    user { seed :user }
    commentable { seed :topic }
    sequence(:body) { |n| "comment_body_#{n}" }
    offtopic false
    review false

    after :build do |comment|
      comment.stub :check_antispam
      comment.stub :check_access
      comment.stub :increment_comments
      comment.stub :creation_callbacks
      comment.stub :subscribe
      comment.stub :notify_quotes
      comment.stub :release_the_banhammer!
    end

    trait :review do
      review true
      body 'x' * Comment::MIN_REVIEW_SIZE
    end

    trait :with_subscribe do
      after(:build) { |comment| comment.unstub :subscribe }
    end

    trait :with_notify_quotes do
      after(:build) { |comment| comment.unstub :notify_quotes }
    end

    trait :with_antispam do
      after(:build) { |comment| comment.unstub :check_antispam }
    end

    trait :with_creation_callbacks do
      after(:build) { |comment| comment.unstub :creation_callbacks }
    end

    trait :with_banhammer do
      after(:build) { |comment| comment.unstub :release_the_banhammer! }
    end
  end
end

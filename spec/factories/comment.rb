FactoryGirl.define do
  factory :comment do
    user
    commentable {|v| FactoryGirl.create(:topic, user: v.user) }
    sequence(:body) { |n| "comment_body_#{n}" }
    offtopic false
    review false

    after(:build) do |comment|
      comment.stub :check_antispam
      comment.stub :check_access
      comment.stub :filter_quotes
      comment.stub :increment_comments
      comment.stub :creation_callbacks
      comment.stub :subscribe
      comment.stub :notify_quotes
    end

    trait :with_subscribe do
      after(:build) do |comment|
        comment.unstub :subscribe
      end
    end

    trait :with_notify_quotes do
      after(:build) do |comment|
        comment.unstub :notify_quotes
      end
    end

    trait :with_antispam do
      after(:build) do |comment|
        comment.unstub :check_antispam
      end
    end

    trait :with_creation_callbacks do
      after(:build) do |comment|
        comment.unstub :creation_callbacks
      end
    end
  end
end

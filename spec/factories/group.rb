FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "group_#{n}" }
    join_policy :free_join

    association :owner, factory: :user
    description ''

    trait :free_join do
      join_policy :free_join
    end

    trait :owner_invite_join do
      join_policy :owner_invite_join
    end

    after :build do |person|
      person.stub :generate_thread
      person.stub :sync_thread
    end

    trait :with_thread do
      after :build do |person|
        person.unstub :generate_thread
      end
    end
  end
end

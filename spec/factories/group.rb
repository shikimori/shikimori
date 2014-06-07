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
  end
end

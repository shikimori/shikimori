FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "group_#{n}" }
    join_policy GroupJoinPolicy::Free

    association :owner, factory: :user
    description ''
  end
end

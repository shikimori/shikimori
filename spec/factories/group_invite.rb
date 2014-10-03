FactoryGirl.define do
  factory :group_invite do
    status GroupInviteStatus::Pending
    group

    association :src, factory: :user
    association :dst, factory: :user

    trait :pending do
      status GroupInviteStatus::Pending
    end

    trait :accepted do
      status GroupInviteStatus::Accepted
    end

    trait :rejected do
      status GroupInviteStatus::Rejected
    end
  end
end

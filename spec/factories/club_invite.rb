FactoryGirl.define do
  factory :club_invite do
    status ClubInviteStatus::Pending
    club

    association :src, factory: :user
    association :dst, factory: :user

    trait :pending do
      status ClubInviteStatus::Pending
    end

    trait :accepted do
      status ClubInviteStatus::Accepted
    end

    trait :rejected do
      status ClubInviteStatus::Rejected
    end
  end
end

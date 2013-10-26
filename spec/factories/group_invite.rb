FactoryGirl.define do
  factory :group_invite do
    status GroupInviteStatus::Pending
    association :group

    association :src, factory: :user
    association :dst, factory: :user
  end
end

FactoryGirl.define do
  factory :group_role do
    group
    user
    role :member

    trait :admin do
      role :admin
    end

    trait :member do
      role :member
    end
  end
end

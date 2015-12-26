FactoryGirl.define do
  factory :club_role do
    club
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

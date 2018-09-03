FactoryBot.define do
  factory :club_role do
    club
    user { seed :user }
    role { :member }

    trait(:admin) { role { :admin } }
    trait(:member) { role { :member } }
  end
end

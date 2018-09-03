FactoryBot.define do
  factory :club_invite do
    status { Types::ClubInvite::Status[:pending] }
    club

    src { seed :user }
    dst { seed :user }

    trait :pending do
      status { Types::ClubInvite::Status[:pending] }
    end

    trait :closed do
      status { Types::ClubInvite::Status[:closed] }
    end
  end
end

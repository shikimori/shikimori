FactoryGirl.define do
  factory :club do
    sequence(:name) { |n| "club_#{n}" }
    join_policy :free_join

    association :owner, factory: :user
    description ''

    after :build do |club|
      club.stub :join_owner
      club.stub :generate_topic
    end

    trait :free_join do
      join_policy :free_join
    end

    trait :owner_invite_join do
      join_policy :owner_invite_join
    end

    trait :linked_anime do
      after :build do |club|
        FactoryGirl.create :club_link, :anime, club: club
      end
    end

    trait :linked_manga do
      after :build do |club|
        FactoryGirl.create :club_link, :manga, club: club
      end
    end

    trait :linked_character do
      after :build do |club|
        FactoryGirl.create :club_link, :character, club: club
      end
    end

    trait :with_member do
      after :build do |club|
        FactoryGirl.create :club_role, club: club
      end
    end

    trait :with_owner_join do
      after :build do |club|
        club.unstub :join_owner
      end
    end

    trait :with_topic do
      after :build do |club|
        club.unstub :generate_topic
      end
    end

    trait :with_logo do
      logo { File.new(Rails.root.join('spec', 'images', 'anime.jpg')) }
    end
  end
end

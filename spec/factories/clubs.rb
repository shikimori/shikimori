FactoryGirl.define do
  factory :club do
    sequence(:name) { |n| "club_#{n}" }
    owner { seed :user }
    description ''

    join_policy Types::Club::JoinPolicy[:free]
    comment_policy Types::Club::CommentPolicy[:free]
    image_upload_policy Types::Club::ImageUploadPolicy[:members]

    locale :ru

    after :build do |club|
      club.class.skip_callback :create, :after, :join_owner
      club.class.skip_callback :create, :after, :assign_style
    end

    trait :with_owner_join do
      after(:build) { |club| club.send :join_owner }
    end
    trait :with_assign_style do
      after(:build) { |club| club.send :assign_style }
    end
    trait :with_topics do
      after(:create) { |club| club.generate_topics club.locale }
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

    trait :with_logo do
      logo { File.new(Rails.root.join('spec', 'images', 'anime.jpg')) }
    end
  end
end

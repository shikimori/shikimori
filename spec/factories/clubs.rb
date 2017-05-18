FactoryGirl.define do
  factory :club do
    sequence(:name) { |n| "club_#{n}" }
    owner { seed :user }
    description ''

    join_policy Types::Club::JoinPolicy[:free]
    comment_policy Types::Club::CommentPolicy[:free]
    image_upload_policy Types::Club::ImageUploadPolicy[:members]

    locale :ru

    after :build do |model|
      stub_method model, :join_owner
      stub_method model, :assign_style
    end

    trait :with_owner_join do
      after(:build) { |model| unstub_method model, :join_owner }
    end
    trait :with_assign_style do
      after(:build) { |model| unstub_method model, :assign_style }
    end
    trait :with_topics do
      after(:create) { |model| model.generate_topics model.locale }
    end

    trait :linked_anime do
      after :build do |model|
        FactoryGirl.create :club_link, :anime, club: model
      end
    end

    trait :linked_manga do
      after :build do |model|
        FactoryGirl.create :club_link, :manga, club: model
      end
    end

    trait :linked_ranobe do
      after :build do |model|
        FactoryGirl.create :club_link, :ranobe, club: model
      end
    end

    trait :linked_character do
      after :build do |model|
        FactoryGirl.create :club_link, :character, club: model
      end
    end

    trait :with_member do
      after :build do |model|
        FactoryGirl.create :club_role, club: model
      end
    end

    trait :with_logo do
      logo { File.new(Rails.root.join('spec', 'images', 'anime.jpg')) }
    end
  end
end

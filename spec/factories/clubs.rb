FactoryBot.define do
  factory :club do
    sequence(:name) { |n| "club_#{n}" }
    owner { seed :user }
    description { '' }

    join_policy { Types::Club::JoinPolicy[:free] }
    comment_policy { Types::Club::CommentPolicy[:free] }
    image_upload_policy { Types::Club::ImageUploadPolicy[:members] }

    locale { :ru }
    is_censored { false }
    is_non_thematic { false }
    is_shadowbanned { false }

    trait(:censored) { is_censored { true } }
    trait(:non_thematic) { is_non_thematic { true } }
    trait(:shadowbanned) { is_shadowbanned { true } }

    after :build do |model|
      stub_method model, :antispam_checks
      stub_method model, :add_to_index
      stub_method model, :join_owner
      stub_method model, :assign_style
      stub_method model, :sync_topics_is_censored
    end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end

    trait :with_owner_join do
      after(:build) { |model| unstub_method model, :join_owner }
    end

    trait :with_assign_style do
      after(:build) { |model| unstub_method model, :assign_style }
    end

    trait :with_sync_topics_is_censored do
      after(:build) { |model| unstub_method model, :sync_topics_is_censored }
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topics model.locale }
    end

    trait :linked_anime do
      after :build do |model|
        FactoryBot.create :club_link, :anime, club: model
      end
    end

    trait :linked_manga do
      after :build do |model|
        FactoryBot.create :club_link, :manga, club: model
      end
    end

    trait :linked_ranobe do
      after :build do |model|
        FactoryBot.create :club_link, :ranobe, club: model
      end
    end

    trait :linked_character do
      after :build do |model|
        FactoryBot.create :club_link, :character, club: model
      end
    end

    trait :linked_club do
      after :build do |model|
        FactoryBot.create :club_link, :club, club: model
      end
    end

    trait :linked_collection do
      after :build do |model|
        FactoryBot.create :club_link, :collection, club: model
      end
    end

    trait :with_member do
      after :build do |model|
        FactoryBot.create :club_role, club: model
      end
    end

    trait :with_logo do
      logo { File.new "#{Rails.root}/spec/files/anime.jpg" }
    end

    trait :faq do
      id { StickyClubView::CLUB_IDS[:faq][:ru] }
      name { 'faq' }
      created_at { 3.days.ago }
      updated_at { 3.days.ago }
    end
  end
end

FactoryGirl.define do
  factory :anime do
    sequence(:name) { |n| "anime_#{n}" }
    sequence(:ranked)
    #sequence(:russian) { |n| "russian_anime_#{n}" }
    description ''
    description_mal ''
    duration 0
    score 1
    mal_scores [1,1,1,1,1,1,1,1,1,1]
    kind 'TV'
    rating 'G - All Ages'
    censored false

    after :build do |anime|
      anime.stub :create_thread
      anime.stub :sync_thread
      anime.stub :check_status
      anime.stub :update_news
    end
    trait :with_callbacks do
      after :build do |anime|
        anime.unstub :check_status
        anime.unstub :update_news
      end
    end
    trait :with_thread do
      after :build do |anime|
        anime.unstub :create_thread
      end
    end
    trait :with_news do
      after :build do |anime|
        anime.unstub :update_news
      end
    end

    trait :with_video do
      after :create do |anime|
        FactoryGirl.create :anime_video, anime: anime
      end
    end

    factory :ongoing_anime do
      status AniMangaStatus::Ongoing
      aired_on DateTime.now - 2.weeks
      duration 0
    end

    factory :anons_anime do
      status AniMangaStatus::Anons
      aired_on DateTime.now + 2.weeks
      episodes_aired 0
      after :create do |anime|
        FactoryGirl.create(:anime_calendar, anime: anime)
      end
    end
  end
end

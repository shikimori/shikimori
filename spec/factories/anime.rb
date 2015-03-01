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
    rating 'PG-13 - Teens 13 or older'
    censored false
    next_episode_at nil

    after :build do |anime|
      anime.stub :generate_thread
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
    trait :with_character do
      after(:build) {|v| FactoryGirl.create :person_role, :character_role, anime: v }
    end
    trait :with_staff do
      after(:build) {|v| FactoryGirl.create :person_role, :staff_role, anime: v }
    end
    trait :with_thread do
      after(:build) {|v| v.unstub :generate_thread }
    end
    trait :with_news do
      after(:build) {|v| v.unstub :update_news }
    end
    trait :with_video do
      after(:create) {|v| FactoryGirl.create :anime_video, anime: v }
    end

    trait :pg_13 do
      rating 'PG-13 - Teens 13 or older'
      censored false
    end

    trait :rx_hentai do
      rating 'Rx - Hentai'
      censored true
    end

    trait :ongoing do
      status AniMangaStatus::Ongoing
      aired_on DateTime.now - 2.weeks
      duration 0
    end

    trait :released do
      status AniMangaStatus::Released
    end

    trait :anons do
      status AniMangaStatus::Anons
      aired_on DateTime.now + 2.weeks
      episodes_aired 0
      after :create do |anime|
        FactoryGirl.create(:anime_calendar, anime: anime)
      end
    end

    trait :with_image do
      image { File.new(Rails.root.join('spec', 'images', 'anime.jpg')) }
    end
  end
end

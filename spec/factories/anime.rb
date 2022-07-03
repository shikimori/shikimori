FactoryBot.define do
  factory :anime do
    sequence(:name) { |n| "anime_#{n}" }
    sequence(:ranked)
    sequence(:russian) { |n| "аниме_#{n}" }
    description_ru { '' }
    description_en { '' }
    duration { 0 }
    score { 1 }
    synonyms { [] }
    kind { :tv }
    status { :released }
    franchise { nil }
    rating { :pg_13 }
    genre_ids { [] }
    studio_ids { [] }
    is_censored { false }
    next_episode_at { nil }
    imageboard_tag { nil }
    coub_tags { [] }
    fansubbers { [] }
    fandubbers { [] }
    options { [] }
    licensors { [] }
    desynced { [] }
    imported_at { nil }
    digital_released_on { nil }
    russia_released_on { nil }
    russia_released_on_hint { '' }

    after :build do |model|
      stub_method model, :track_changes
      stub_method model, :generate_news
      stub_method model, :generate_name_matches

      stub_method model, :touch_related
    end

    trait :with_track_changes do
      after(:build) { |model| unstub_method model, :track_changes }
    end

    trait :with_callbacks do
      after :build do |model|
        unstub_method model, :track_changes
        unstub_method model, :generate_news
      end
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topics :ru }
    end

    trait :with_character do
      after(:build) { |model| FactoryBot.create :person_role, :character_role, anime: model }
    end

    trait :with_staff do
      after(:build) { |model| FactoryBot.create :person_role, :staff_role, anime: model }
    end

    trait :with_news do
      after(:build) { |model| unstub_method model, :update_news }
    end

    trait :with_video do
      after(:create) { |model| FactoryBot.create :anime_video, anime: model }
    end

    Anime.kind.values.each do |kind_type|
      trait kind_type do
        kind { kind_type }
      end
    end

    Types::Anime::Options.values.each do |option_type|
      trait option_type do
        options { [option_type] }
      end
    end

    trait :with_mal_id do
      mal_id { 1 }
    end

    trait :pg_13 do
      rating { :pg_13 }
      is_censored { false }
    end

    trait :rx_hentai do
      rating { :rx }
      is_censored { true }
    end

    trait :ongoing do
      status { :ongoing }
      aired_on { 2.weeks.ago }
      duration { 0 }
    end

    trait :released do
      status { :released }
    end

    trait :anons do
      status { :anons }
      aired_on { 2.weeks.from_now }
      episodes_aired { 0 }

      # after :create do |anime|
        # FactoryBot.create(:anime_calendar, anime: anime)
      # end
    end

    trait :with_image do
      image { File.new "#{Rails.root}/spec/files/anime.jpg" }
    end
  end
end

FactoryBot.define do
  factory :manga do
    sequence(:name) { |n| "manga_#{n}" }
    sequence(:ranked)
    sequence(:ranked_shiki)
    sequence(:ranked_random)
    sequence(:russian) { |n| "манга_#{n}" }
    description_ru { '' }
    description_en { '' }
    score { 1 }
    kind { :manga }
    status { :released }
    franchise { nil }
    publisher_ids { [] }
    is_censored { false }
    type { Manga.name }
    imageboard_tag { '' }
    licensors { [] }
    desynced { [] }
    imported_at { nil }
    options { [] }
    aired_on { {} }
    aired_on_computed { nil }
    released_on { {} }

    factory :ranobe, class: 'Ranobe' do
      sequence(:name) { |n| "ranobe_#{n}" }
      sequence(:russian) { |n| "ранобэ_#{n}" }
      type { Ranobe.name }
      kind { Ranobe::KINDS.first }
    end

    trait :with_mal_id do
      mal_id { 1 }
    end

    after :build do |model|
      stub_method model, :generate_name_matches
      stub_method model, :touch_related
      stub_method model, :sync_topics_is_censored
    end

    trait :with_sync_topics_is_censored do
      after(:build) { |model| unstub_method model, :sync_topics_is_censored }
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topics :ru }
    end

    Manga.kind.values.each do |kind_type|
      trait kind_type do
        kind { kind_type }
      end
    end

    trait :ongoing do
      status { :ongoing }
      aired_on { IncompleteDate.parse 2.weeks.ago }
    end

    trait :released do
      status { :released }
    end

    trait :discontinued do
      status { :released }
    end

    trait :anons do
      status { :anons }
      aired_on { IncompleteDate.parse 2.weeks.from_now }
    end
  end
end

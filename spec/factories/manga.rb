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
    released_on_computed { nil }

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
      # for some reasons "aired_on=" from IncompleteDate::ComputedField is
      # not evoked when attributes are set as factory attributes
      model.aired_on_computed = model.aired_on.date if model.aired_on.present?
      model.released_on_computed = model.released_on.date if model.released_on.present?

      stub_method model, :generate_name_matches
      stub_method model, :touch_related
      stub_method model, :sync_topics_is_censored
    end

    trait :with_sync_topics_is_censored do
      after(:build) { |model| unstub_method model, :sync_topics_is_censored }
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topic }
    end

    Manga.kind.values.each do |kind_type|
      trait kind_type do
        kind { kind_type }
      end
    end

    trait :ongoing do
      status { :ongoing }
      aired_on { 2.weeks.ago }
    end

    trait :released do
      status { :released }
    end

    trait :discontinued do
      status { :released }
    end

    trait :anons do
      status { :anons }
      aired_on { 2.weeks.from_now }
    end
  end
end

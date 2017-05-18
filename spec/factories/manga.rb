FactoryGirl.define do
  factory :manga do
    sequence(:name) { |n| "manga_#{n}" }
    sequence(:ranked)
    sequence(:russian) { |n| "манга_#{n}" }
    description_ru ''
    description_en ''
    score 1
    kind :manga
    type { Manga.name }

    factory :ranobe, class: 'Ranobe' do
      sequence(:name) { |n| "ranobe_#{n}" }
      sequence(:russian) { |n| "ранобэ_#{n}" }
      type Ranobe.name
      kind Ranobe::KIND
    end

    after :build do |model|
      stub_method model, :generate_name_matches

      stub_method model, :touch_related

      stub_method model, :post_elastic
      stub_method model, :put_elastic
      stub_method model, :delete_elastic
    end

    trait :with_elasticserach do
      after :build do |model|
        unstub_method model, :post_elastic
        unstub_method model, :put_elastic
        unstub_method model, :delete_elastic
      end
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topics :ru }
    end

    Manga.kind.values.each do |kind_type|
      trait kind_type do
        kind kind_type
      end
    end
  end
end

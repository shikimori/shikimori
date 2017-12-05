FactoryBot.define do
  factory :character do
    sequence(:name) { |n| "character_#{n}" }
    sequence(:russian) { |n| "персонаж_#{n}" }
    description_ru ''
    description_en ''

    after :build do |model|
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

    trait :anime do
      after :create do |character|
        FactoryBot.create :anime, characters: [character]
      end
    end

    trait :with_topics do
      after(:create) { |character| character.generate_topics :ru }
    end
  end
end

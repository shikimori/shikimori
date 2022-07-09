FactoryBot.define do
  factory :character do
    sequence(:name) { |n| "character_#{n}" }
    sequence(:russian) { |n| "персонаж_#{n}" }
    japanese { '' }
    fullname { '' }
    description_ru { '' }
    description_en { '' }
    desynced { [] }
    imageboard_tag { '' }
    is_anime { false }
    is_manga { false }
    is_ranobe { false }
    mal_id { nil }

    after :build do |model|
      stub_method model, :touch_related
    end

    trait :anime do
      after :create do |character|
        create :anime, characters: [character]
      end
    end

    trait :with_topics do
      after(:create) { |character| character.generate_topics :ru }
    end
  end
end

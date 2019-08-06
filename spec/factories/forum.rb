FactoryBot.define do
  factory :forum do
    sequence(:name_ru) { |n| "форум_#{n}" }
    sequence(:name_en) { |n| "forum_#{n}" }
    permalink { :offtopic }
    position { 0 }

    trait :offtopic do
      id { (Random.rand * 100_000).to_i }
      permalink { 'offtopic' }
    end

    trait :animanga do
      id { Topic::FORUM_IDS[Anime.name] }
      permalink { 'animanga' }
      name_ru { 'Аниме и манга' }
    end

    trait :contest do
      id { Topic::FORUM_IDS[Contest.name] }
      permalink { 'contests' }
      name_ru { 'Турниры' }
    end

    trait :club do
      id { Topic::FORUM_IDS[Club.name] }
      permalink { 'clubs' }
      name_ru { 'Клубы' }
    end

    trait :collection do
      id { Topic::FORUM_IDS[Collection.name] }
      permalink { 'collections' }
      name_ru { 'Клубы' }
    end

    trait :cosplay do
      id { Topic::FORUM_IDS[CosplayGallery.name] }
      permalink { 'cosplay' }
      name_ru { 'Косплей' }
    end

    trait :reviews do
      id { Topic::FORUM_IDS[Review.name] }
      permalink { 'reviews' }
      name_ru { 'Рецензии' }
    end

    factory :animanga_forum, traits: [:animanga]
    factory :reviews_forum, traits: [:reviews]
    factory :offtopic_forum, traits: [:offtopic]
    factory :contests_forum, traits: [:contest]
    factory :clubs_forum, traits: [:club]
    factory :collections_forum, traits: [:collection]
    factory :cosplay_forum, traits: [:cosplay]
  end
end

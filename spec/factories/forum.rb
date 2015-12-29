FactoryGirl.define do
  factory :forum do
    sequence(:name_ru) { |n| "форум_#{n}" }
    sequence(:name_en) { |n| "forum_#{n}" }
    permalink :offtopic
    position 0

    trait :offtopic do
      id (Random.rand * 100_000).to_i
      permalink 'offtopic'
      is_visible true
    end

    trait :animanga do
      id { DbEntryThread::FORUM_IDS['Anime'] }
      permalink 'animanga'
      name_ru 'Аниме и манга'
      is_visible true
    end

    trait :contest do
      id { DbEntryThread::FORUM_IDS['Contest'] }
      permalink 'contests'
      name_ru 'Опросы'
    end

    trait :club do
      id { DbEntryThread::FORUM_IDS['Club'] }
      permalink 'clubs'
      name_ru 'Клубы'
    end

    trait :cosplay do
      id { DbEntryThread::FORUM_IDS['CosplayGallery'] }
      permalink 'cosplay'
      name_ru 'Косплей'
    end

    trait :reviews do
      id { DbEntryThread::FORUM_IDS['Review'] }
      permalink 'reviews'
      name_ru 'Рецензии'
    end

    factory :animanga_forum, traits: [:animanga]
    factory :reviews_forum, traits: [:reviews]
    factory :offtopic_forum, traits: [:offtopic]
    factory :contests_forum, traits: [:contest]
    factory :clubs_forum, traits: [:club]
    factory :cosplay_forum, traits: [:cosplay]
  end
end

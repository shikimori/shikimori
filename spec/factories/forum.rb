FactoryGirl.define do
  factory :forum do
    sequence(:name) { |n| "forum_#{n}" }
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
      name 'Аниме и манга'
      is_visible true
    end

    trait :contest do
      id { DbEntryThread::FORUM_IDS['Contest'] }
      permalink 'contests'
      name 'Опросы'
    end

    trait :club do
      id { DbEntryThread::FORUM_IDS['Group'] }
      permalink 'clubs'
      name 'Клубы'
    end

    trait :cosplay do
      id { DbEntryThread::FORUM_IDS['CosplayGallery'] }
      permalink 'cosplay'
      name 'Косплей'
    end

    trait :reviews do
      id { DbEntryThread::FORUM_IDS['Review'] }
      permalink 'reviews'
      name 'Рецензии'
    end

    factory :animanga_forum, traits: [:animanga]
    factory :reviews_forum, traits: [:reviews]
    factory :offtopic_forum, traits: [:offtopic]
    factory :contests_forum, traits: [:contest]
    factory :clubs_forum, traits: [:club]
    factory :cosplay_forum, traits: [:cosplay]
  end
end

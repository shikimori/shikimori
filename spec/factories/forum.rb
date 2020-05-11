FactoryBot.define do
  factory :forum do
    sequence(:name_ru) { |n| "форум_#{n}" }
    sequence(:name_en) { |n| "forum_#{n}" }
    permalink { :offtopic }
    position { 0 }

    trait :animanga do
      id { Topic::FORUM_IDS[Anime.name] }
      permalink { 'animanga' }
      name_ru { 'Аниме и манга' }
    end

    trait :club do
      id { Topic::FORUM_IDS[Club.name] }
      permalink { 'clubs' }
      name_ru { 'Клубы' }
    end

    trait :collection do
      id { Topic::FORUM_IDS[Collection.name] }
      permalink { 'collections' }
      name_ru { 'Коллекции' }
    end

    trait :articles do
      id { Topic::FORUM_IDS[Article.name] }
      permalink { 'articles' }
      name_ru { 'Статьи' }
    end

    trait :contest do
      id { Topic::FORUM_IDS[Contest.name] }
      permalink { 'contests' }
      name_ru { 'Турниры' }
    end

    trait :cosplay do
      id { Topic::FORUM_IDS[CosplayGallery.name] }
      permalink { 'cosplay' }
      name_ru { 'Косплей' }
    end

    trait :news do
      id { Forum::NEWS_ID }
      permalink { 'news' }
      name_ru { 'Новости' }
    end

    trait :offtopic do
      id { Forum::OFFTOPIC_ID }
      permalink { 'offtopic' }
    end

    trait :reviews do
      id { Topic::FORUM_IDS[Review.name] }
      permalink { 'reviews' }
      name_ru { 'Рецензии' }
    end

    trait :premoderation do
      id { Forum::PREMODERATION_ID }
      permalink { 'premoderation' }
      name_ru { 'Премодерация' }
    end

    factory :animanga_forum, traits: %i[animanga]
    factory :clubs_forum, traits: %i[club]
    factory :collections_forum, traits: %i[collection]
    factory :articles_forum, traits: %i[articles]
    factory :contests_forum, traits: %i[contest]
    factory :cosplay_forum, traits: %i[cosplay]
    factory :news_forum, traits: %i[news]
    factory :offtopic_forum, traits: %i[offtopic]
    factory :reviews_forum, traits: %i[reviews]
    factory :premoderation_forum, traits: %i[premoderation]
  end
end

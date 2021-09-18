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
      name_en { 'Anime and manga' }
    end

    trait :club do
      id { Topic::FORUM_IDS[Club.name] }
      permalink { 'clubs' }
      name_ru { 'Клубы' }
      name_en { 'Clubs' }
    end

    trait :collection do
      id { Topic::FORUM_IDS[Collection.name] }
      permalink { 'collections' }
      name_ru { 'Коллекции' }
      name_en { 'Collections' }
    end

    trait :articles do
      id { Topic::FORUM_IDS[Article.name] }
      permalink { 'articles' }
      name_ru { 'Статьи' }
      name_en { 'Articles' }
    end

    trait :contest do
      id { Topic::FORUM_IDS[Contest.name] }
      permalink { 'contests' }
      name_ru { 'Турниры' }
      name_en { 'Contests' }
    end

    trait :cosplay do
      id { Topic::FORUM_IDS[CosplayGallery.name] }
      permalink { 'cosplay' }
      name_ru { 'Косплей' }
      name_en { 'Cosplay' }
    end

    trait :news do
      id { Forum::NEWS_ID }
      permalink { 'news' }
      name_ru { 'Новости' }
      name_en { 'News' }
    end

    trait :offtopic do
      id { Forum::OFFTOPIC_ID }
      permalink { 'offtopic' }
      name_ru { 'Оффтопик' }
      name_en { 'Offtopic' }
    end

    trait :critiques do
      id { Topic::FORUM_IDS[Critique.name] }
      permalink { 'critiques' }
      name_ru { 'Рецензии' }
      name_en { 'Critiques' }
    end

    trait :premoderation do
      id { Forum::PREMODERATION_ID }
      permalink { 'premoderation' }
      name_ru { 'Премодерация' }
      name_en { 'Premoderation' }
    end

    trait :hidden do
      id { Forum::HIDDEN_ID }
      permalink { 'hidden' }
      name_ru { 'Скрытый' }
      name_en { 'Hidden' }
    end

    factory :animanga_forum, traits: %i[animanga]
    factory :clubs_forum, traits: %i[club]
    factory :collections_forum, traits: %i[collection]
    factory :articles_forum, traits: %i[articles]
    factory :contests_forum, traits: %i[contest]
    factory :cosplay_forum, traits: %i[cosplay]
    factory :news_forum, traits: %i[news]
    factory :offtopic_forum, traits: %i[offtopic]
    factory :critiques_forum, traits: %i[reviews]
    factory :premoderation_forum, traits: %i[premoderation]
    factory :hidden_forum, traits: %i[hidden]
  end
end

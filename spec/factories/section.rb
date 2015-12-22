FactoryGirl.define do
  factory :section do
    sequence(:name) { |n| "section_#{n}" }
    permalink :offtopic
    position 0

    trait :offtopic do
      id (Random.rand * 100_000).to_i
      permalink 'offtopic'
      is_visible true
    end

    trait :animanga do
      id { DbEntryThread::SectionIDs['Anime'] }
      permalink 'animanga'
      name 'Аниме и манга'
      is_visible true
    end

    trait :contest do
      id { DbEntryThread::SectionIDs['Contest'] }
      permalink 'contests'
      name 'Опросы'
    end

    trait :club do
      id { DbEntryThread::SectionIDs['Group'] }
      permalink 'clubs'
      name 'Клубы'
    end

    trait :cosplay do
      id { DbEntryThread::SectionIDs['CosplayGallery'] }
      permalink 'cosplay'
      name 'Косплей'
    end

    trait :reviews do
      id { DbEntryThread::SectionIDs['Review'] }
      permalink 'reviews'
      name 'Рецензии'
    end

    factory :animanga_section, traits: [:animanga]
    factory :reviews_section, traits: [:reviews]
    factory :offtopic_section, traits: [:offtopic]
    factory :contests_section, traits: [:contest]
  end
end

FactoryGirl.define do
  factory :section do
    sequence(:name) { |n| "section_#{n}" }
    permalink :o
    position 0

    trait :offtopic do
      id (Random.rand * 100_000).to_i
      permalink 'o'
    end

    trait :anime do
      id { DbEntryThread::SectionIDs['Anime'] }
      permalink 'a'
      name 'Аниме'
    end

    trait :character do
      id { DbEntryThread::SectionIDs['Character'] }
      permalink 'c'
      name 'Персонажи'
    end

    trait :person do
      id { DbEntryThread::SectionIDs['Person'] }
      permalink 'p'
      name 'Люди'
    end

    trait :contest do
      id { DbEntryThread::SectionIDs['Contest'] }
      permalink 'v'
      name 'Люди'
    end

    trait :club do
      id { DbEntryThread::SectionIDs['Group'] }
      permalink 'g'
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

    factory :offtopic_section, traits: [:offtopic]
  end
end

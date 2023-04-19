FactoryBot.define do
  factory :genre do
    sequence(:name) { |n| "genre_#{n}" }
    sequence(:mal_id) { |n| n }
    entry_type { Types::Genre::EntryType['Anime'] }

    trait(:anime) { entry_type { Types::Genre::EntryType['Anime'] } }
    trait(:manga) { entry_type { Types::Genre::EntryType['Manga'] } }
  end
end

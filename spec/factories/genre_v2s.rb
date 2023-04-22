FactoryBot.define do
  factory :genre_v2 do
    sequence(:name) { |n| "Genre #{n}" }
    sequence(:russian) { |n| "Жанр #{n}" }
    entry_type { Types::Genre::EntryType['Anime'] }
    kind { Types::Genre::Kind[:genre] }
    description { '' }
    mal_id { nil }
    is_active { false }
    position { 99 }
    seo { 99 }

    Types::Genre::Kind.values.each do |v|
      trait(v.to_sym) { kind { v } }
    end

    Types::Genre::EntryType.values.each do |v|
      trait(v.downcase.to_sym) { entry_type { v } }
    end
  end
end

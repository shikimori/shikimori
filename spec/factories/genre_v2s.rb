FactoryBot.define do
  factory :genre_v2 do
    sequence(:name) { |n| "Genre #{n}" }
    sequence(:russian) { |n| "Жанр #{n}" }
    entry_type { Types::GenreV2::EntryType['Anime'] }
    kind { Types::GenreV2::Kind[:genre] }
    description { '' }
    is_censored { false }
    is_active { true }
    position { 99 }
    seo { 99 }
    mal_id { nil }

    Types::GenreV2::Kind.values.each do |v|
      trait(v.to_sym) { kind { v } }
    end

    Types::GenreV2::EntryType.values.each do |v|
      trait(v.downcase.to_sym) { entry_type { v } }
    end
  end
end

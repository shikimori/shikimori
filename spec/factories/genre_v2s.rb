FactoryBot.define do
  factory :genre_v2 do
    sequence(:name) { |n| "Genre #{n}" }
    sequence(:russian) { |n| "Жанр #{n}" }
    kind { Types::GenreV2::Kind[:genre] }
    description { '' }
    sequence(:mal_id) { |n| n }
    is_censored { false }
    is_active { true }
    position { 99 }
    seo { 99 }

    Types::GenreV2::Kind.values.each do |v|
      trait(v.to_sym) { kind { v } }
    end
  end
end

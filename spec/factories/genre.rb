FactoryBot.define do
  factory :genre do
    sequence(:name) { |n| "genre #{n}" }
    sequence(:mal_id) { |n| n }
    sequence(:russian) { |n| "жанр #{n}" }
    kind { 'anime' }

    trait(:anime) { kind { 'anime' } }
    trait(:manga) { kind { 'manga' } }
  end
end

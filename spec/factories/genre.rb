FactoryBot.define do
  factory :genre do
    sequence(:name) { |n| "genre_#{n}" }
    sequence(:mal_id) { |n| n }
    kind 'anime'

    trait(:anime) { kind 'anime' }
    trait(:manga) { kind 'manga' }
  end
end

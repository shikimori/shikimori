FactoryGirl.define do
  factory :manga do
    sequence(:name) { |n| "manga_#{n}" }
    sequence(:ranked)
    sequence(:russian) { |n| "манга_#{n}" }
    description_mal ''
    score 1
    mal_scores [1,1,1,1,1,1,1,1,1,1]
    kind "Manga"

    after(:build) do |anime|
      anime.stub :create_thread
      anime.stub :sync_thread
    end
    trait :with_thread do
      after(:build) do |anime|
        anime.unstub :create_thread
      end
    end
  end
end

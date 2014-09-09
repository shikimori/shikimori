FactoryGirl.define do
  factory :character do
    sequence(:name) { |n| "character_#{n}" }
    sequence(:russian) { |n| "персонаж_#{n}" }
    after(:create) { |a| FactoryGirl.create(:anime, :characters => [a]) }
    description ''
    description_mal ''

    after(:build) do |anime|
      anime.stub :generate_thread
      anime.stub :sync_thread
    end
    trait :with_thread do
      after(:build) do |anime|
        anime.unstub :generate_thread
      end
    end
  end
end

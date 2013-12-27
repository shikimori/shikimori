FactoryGirl.define do
  factory :character do
    sequence(:name) { |n| "character_#{n}" }
    sequence(:russian) { |n| "персонаж_#{n}" }
    after(:create) { |a| FactoryGirl.create(:anime, :characters => [a]) }
    description ''
    description_mal ''
  end
end

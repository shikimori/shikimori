FactoryGirl.define do
  factory :character do
    sequence(:name) { |n| "character_#{n}" }
    sequence(:russian) { |n| "персонаж_#{n}" }
    description_ru ''
    description_en ''

    after :build do |character|
      character.stub :generate_thread
      character.stub :sync_thread
    end

    trait :anime do
      after :create do |character|
        FactoryGirl.create :anime, characters: [character]
      end
    end

    trait :with_thread do
      after :build do |character|
        character.unstub :generate_thread
      end
    end
  end
end

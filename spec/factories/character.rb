FactoryGirl.define do
  factory :character do
    sequence(:name) { |n| "character_#{n}" }
    sequence(:russian) { |n| "персонаж_#{n}" }
    description_ru ''
    description_en ''

    after :build do |character|
      character.class.skip_callback :update, :after, :touch_related

      character.class.skip_callback :create, :after, :post_elastic
      character.class.skip_callback :update, :after, :put_elastic
      character.class.skip_callback :destroy, :after, :delete_elastic
    end

    trait :with_elasticserach do
      after :build do |character|
        character.class.set_callback :create, :after, :post_elastic
        character.class.set_callback :update, :after, :put_elastic
        character.class.set_callback :destroy, :after, :delete_elastic
      end
    end

    trait :anime do
      after :create do |character|
        FactoryGirl.create :anime, characters: [character]
      end
    end

    trait :with_topics do
      after(:create) { |character| character.generate_topics :ru }
    end
  end
end

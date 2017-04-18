FactoryGirl.define do
  factory :collection do
    sequence(:name) { |n| "Collection #{n}" }
    user { seed :user }
    locale :ru

    trait :with_topics do
      after(:create) { |model| model.generate_topics model.locale }
    end
  end
end

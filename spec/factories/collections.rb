FactoryGirl.define do
  factory :collection do
    sequence(:name) { |n| "Collection #{n}" }
    user { seed :user }
    kind :anime
    text ''
    locale :ru

    Types::Collection::Kind.values.each { |value| trait(value) { kind value } }

    trait :with_topics do
      after(:create) { |model| model.generate_topics model.locale }
    end
  end
end

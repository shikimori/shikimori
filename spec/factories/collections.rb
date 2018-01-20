FactoryBot.define do
  factory :collection do
    sequence(:name) { |n| "Collection #{n}" }
    user { seed :user }
    kind :anime
    state :unpublished
    text ''
    locale :ru

    Types::Collection::State.values.each { |value| trait(value) { state value } }
    Types::Collection::Kind.values.each { |value| trait(value) { kind value } }

    after :build do |model|
      stub_method model, :check_antispam
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topics model.locale }
    end
  end
end

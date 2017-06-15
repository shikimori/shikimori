FactoryGirl.define do
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
      stub_method model, :post_elastic
      stub_method model, :put_elastic
      stub_method model, :delete_elastic
    end

    trait(:pending) { state :pending }
    trait(:published) { state :published }

    trait :with_topics do
      after(:create) { |model| model.generate_topics model.locale }
    end

    trait :with_elasticserach do
      after :build do |model|
        unstub_method model, :post_elastic
        unstub_method model, :put_elastic
        unstub_method model, :delete_elastic
      end
    end
  end
end

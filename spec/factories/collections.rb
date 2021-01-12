FactoryBot.define do
  factory :collection do
    sequence(:name) { |n| "Collection #{n}" }
    user { seed :user }
    kind { :anime }
    state { :unpublished }
    moderation_state { :pending }
    text { '' }
    locale { :ru }
    published_at { nil }
    changed_at { nil }

    Collection.state_machine.states.map(&:value).each do |value|
      trait(value.to_sym) { state { value } }
    end

    Types::Collection::Kind.values.each { |value| trait(value) { kind { value } } }

    after :build do |model|
      stub_method model, :antispam_checks
    end

    trait(:pending) { moderation_state { :pending } }
    trait(:accepted) { moderation_state { :accepted } }
    trait(:rejected) { moderation_state { :rejected } }

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
    trait :with_topics do
      after(:create) { |model| model.generate_topics model.locale }
    end
  end
end

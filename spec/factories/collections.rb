FactoryBot.define do
  factory :collection do
    sequence(:name) { |n| "Collection #{n}" }
    user { seed :user }
    kind { :anime }
    state { :unpublished }
    moderation_state { :pending }
    text { '' }
    tags { [] }
    published_at { nil }
    changed_at { nil }
    links_count { 0 }
    is_censored { true }

    Collection.aasm.states.map(&:name).each do |value|
      trait(value.to_sym) { state { value } }
    end

    Collection.aasm(:moderation_state).states.map(&:name).each do |value|
      trait(value.to_sym) { moderation_state { value } }
    end

    Types::Collection::Kind.values.each do |value|
      trait(value) { kind { value } }
    end

    Types::Collection::Kind.values.each do |value|
      trait(value) { kind { value } }
    end

    after :build do |model|
      stub_method model, :antispam_checks
      stub_method model, :sync_topics_is_censored
    end

    trait :with_sync_topics_is_censored do
      after(:build) { |model| unstub_method model, :sync_topics_is_censored }
    end

    trait(:pending) { moderation_state { :pending } }
    trait(:accepted) { moderation_state { :accepted } }
    trait(:rejected) { moderation_state { :rejected } }

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
  end
end

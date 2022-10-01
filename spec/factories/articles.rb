FactoryBot.define do
  factory :article do
    name { 'article name' }
    user { seed :user }
    body { 'article text' }
    state { :unpublished }
    moderation_state { 'pending' }
    approver_id { nil }
    tags { [] }
    changed_at { nil }

    Types::Article::State.values.each do |value|
      trait(value) { state { value } }
    end

    Article.aasm(:moderation_state).states.map(&:name).each do |value|
      trait(value.to_sym) { moderation_state { value } }
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topic }
    end

    after :build do |model|
      stub_method model, :antispam_checks
    end

    trait(:pending) { moderation_state { :pending } }
    trait(:accepted) { moderation_state { :accepted } }
    trait(:rejected) { moderation_state { :rejected } }

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
  end
end

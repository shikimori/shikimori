FactoryBot.define do
  factory :critique do
    association :target, factory: :anime
    user { seed :user }
    text { 's' * Critique::MIN_BODY_SIZE }
    changed_at { nil }

    overall { 1 }
    storyline { 1 }
    music { 1 }
    characters { 1 }
    animation { 1 }

    cached_votes_up { 0 }
    cached_votes_down { 0 }

    after :build do |model|
      stub_method model, :antispam_checks
    end

    trait(:pending) { moderation_state { :pending } }
    trait(:accepted) { moderation_state { :accepted } }
    trait(:rejected) { moderation_state { :rejected } }

    Critique.aasm(:moderation_state).states.map(&:name).each do |value|
      trait(value.to_sym) { moderation_state { value } }
    end

    trait :with_topics do
      after(:create) { |critique| critique.generate_topic }
    end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
  end
end

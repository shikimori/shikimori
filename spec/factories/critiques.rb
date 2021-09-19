FactoryBot.define do
  factory :critique do
    association :target, factory: :anime
    user { seed :user }
    text { 's' * Critique::MINIMUM_LENGTH }
    changed_at { nil }

    overall { 1 }
    storyline { 1 }
    music { 1 }
    characters { 1 }
    animation { 1 }

    locale { :ru }

    cached_votes_up { 0 }
    cached_votes_down { 0 }

    after :build do |model|
      stub_method model, :antispam_checks
    end

    trait(:pending) { moderation_state { :pending } }
    trait(:accepted) { moderation_state { :accepted } }
    trait(:rejected) { moderation_state { :rejected } }

    # Critique.state_machine.states.map(&:value).each do |critique_state|
      # trait(critique_state.to_sym) { moderation_state critique_state }
    # end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
    trait :with_topics do
      after(:create) { |critique| critique.generate_topics critique.locale }
    end
  end
end

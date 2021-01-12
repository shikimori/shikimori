FactoryBot.define do
  factory :review do
    association :target, factory: :anime
    user { seed :user }
    text { 's' * Review::MINIMUM_LENGTH }
    changed_at { nil }

    overall { 1 }
    storyline { 1 }
    music { 1 }
    characters { 1 }
    animation { 1 }

    locale { :ru }

    after :build do |model|
      stub_method model, :antispam_checks
    end

    trait(:pending) { moderation_state { :pending } }
    trait(:accepted) { moderation_state { :accepted } }
    trait(:rejected) { moderation_state { :rejected } }

    # Review.state_machine.states.map(&:value).each do |review_state|
      # trait(review_state.to_sym) { moderation_state review_state }
    # end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
    trait :with_topics do
      after(:create) { |review| review.generate_topics review.locale }
    end
  end
end

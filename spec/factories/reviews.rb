FactoryBot.define do
  factory :review do
    user { seed :user }
    anime { nil }
    manga { nil }
    body { 'a' * Review::MIN_BODY_SIZE }
    opinion { Types::Review::Opinion[:neutral] }
    is_written_before_release { false }
    changed_at { nil }

    comments_count { 0 }
    cached_votes_up { 0 }
    cached_votes_down { 0 }

    after :build do |model|
      stub_method model, :antispam_checks
    end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end

    Types::Review::Opinion.values.each do |value|
      trait(value) { opinion { value } }
    end
  end
end

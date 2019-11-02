FactoryBot.define do
  factory :article do
    name { 'article name' }
    user { seed :user }
    text { 'article text' }
    moderation_state { 'pending' }
    approver_id { nil }
    tags { [] }
    locale { :ru }

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

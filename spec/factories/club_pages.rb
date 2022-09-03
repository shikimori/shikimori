FactoryBot.define do
  factory :club_page do
    club { nil }
    user { seed :user }
    parent_page { nil }
    name { 'MyString' }
    text { 'MyText' }

    after :build do |model|
      stub_method model, :antispam_checks
    end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
  end
end

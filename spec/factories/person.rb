FactoryBot.define do
  factory :person do
    sequence(:name) { |n| "person_#{n}" }

    after :create do |person|
      FactoryBot.create :anime, person_roles: [
        FactoryBot.create(:person_role, role: 'Producer', person: person)
      ]
    end

    after :build do |model|
      stub_method model, :touch_related
    end

    trait :with_topics do
      after(:create) { |model| model.generate_topics :ru }
    end
  end
end

FactoryGirl.define do
  factory :person do
    sequence(:name) { |n| "person_#{n}" }

    after :create do |person|
      person.class.skip_callback :update, :after, :touch_related

      FactoryGirl.create :anime, person_roles: [
          FactoryGirl.create(:person_role, role: 'Producer', person: person)
        ]
    end

    trait :with_topics do
      after(:create) { |v| v.generate_topics :ru }
    end
  end
end

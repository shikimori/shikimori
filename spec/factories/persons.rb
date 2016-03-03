FactoryGirl.define do
  factory :person do
    sequence(:name) { |n| "person_#{n}" }
    after :create do |person|
      FactoryGirl.create :anime, person_roles: [
          FactoryGirl.create(:person_role, role: 'Producer', person: person)
        ]
    end

    after :build do |person|
      person.stub :generate_topic
    end

    trait :with_topic do
      after :build do |person|
        person.unstub :generate_topic
      end
    end
  end
end

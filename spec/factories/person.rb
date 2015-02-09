FactoryGirl.define do
  factory :person do
    sequence(:name) { |n| "prson_#{n}" }
    after :create do |person|
      FactoryGirl.create :anime, person_roles: [
          FactoryGirl.create(:person_role, role: 'Producer', person: person)
        ]
    end

    after :build do |person|
      person.stub :generate_thread
      person.stub :sync_thread
    end

    trait :with_thread do
      after :build do |person|
        person.unstub :generate_thread
      end
    end
  end
end

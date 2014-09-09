FactoryGirl.define do
  factory :person do
    sequence(:name) { |n| "prson_#{n}" }
    after :create do |person|
      FactoryGirl.create :anime, person_roles: [
          FactoryGirl.create(:person_role, role: 'Producer', person: person)
        ]
    end

    after(:build) do |anime|
      anime.stub :generate_thread
      anime.stub :sync_thread
    end
    trait :with_thread do
      after(:build) do |anime|
        anime.unstub :generate_thread
      end
    end
  end
end

FactoryGirl.define do
  factory :person do
    sequence(:name) { |n| "person_#{n}" }

    after :create do |person|
      FactoryGirl.create :anime, person_roles: [
        FactoryGirl.create(:person_role, role: 'Producer', person: person)
      ]
    end

    after :build do |model|
      stub_method model, :touch_related

      stub_method model, :post_elastic
      stub_method model, :put_elastic
      stub_method model, :delete_elastic
    end

    trait :with_elasticserach do
      after :build do |model|
        unstub_method model, :post_elastic
        unstub_method model, :put_elastic
        unstub_method model, :delete_elastic
      end
    end


    trait :with_topics do
      after(:create) { |model| model.generate_topics :ru }
    end
  end
end

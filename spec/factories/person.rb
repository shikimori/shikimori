FactoryGirl.define do
  factory :person do
    sequence(:name) { |n| "person_#{n}" }

    after :create do |person|
      FactoryGirl.create :anime, person_roles: [
        FactoryGirl.create(:person_role, role: 'Producer', person: person)
      ]
    end

    after :build do |person|
      person.class.skip_callback :update, :after, :touch_related

      person.class.skip_callback :create, :after, :post_elastic
      person.class.skip_callback :update, :after, :put_elastic
      person.class.skip_callback :destroy, :after, :delete_elastic
    end

    trait :with_elasticserach do
      after :build do |person|
        person.class.set_callback :create, :after, :post_elastic
        person.class.set_callback :update, :after, :put_elastic
        person.class.set_callback :destroy, :after, :delete_elastic
      end
    end


    trait :with_topics do
      after(:create) { |v| v.generate_topics :ru }
    end
  end
end

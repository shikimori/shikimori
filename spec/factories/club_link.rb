FactoryGirl.define do
  factory :club_link do
    club nil
    linked nil

    trait :anime do
      linked { FactoryGirl.create :anime }
    end

    trait :manga do
      linked { FactoryGirl.create :manga }
    end

    trait :ranobe do
      linked_id { FactoryGirl.create(:ranobe).id }
      linked_type { Ranobe.name }
    end

    trait :character do
      linked { FactoryGirl.create :character }
    end
  end
end

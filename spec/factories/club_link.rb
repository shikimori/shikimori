FactoryBot.define do
  factory :club_link do
    club { nil }
    linked { nil }

    trait :anime do
      linked { FactoryBot.create :anime }
    end

    trait :manga do
      linked { FactoryBot.create :manga }
    end

    trait :ranobe do
      linked_id { FactoryBot.create(:ranobe).id }
      linked_type { Ranobe.name }
    end

    trait :character do
      linked { FactoryBot.create :character }
    end

    trait :club do
      linked { FactoryBot.create :club }
    end

    trait :collection do
      linked { FactoryBot.create :collection }
    end
  end
end

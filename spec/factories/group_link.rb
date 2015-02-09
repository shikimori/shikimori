FactoryGirl.define do
  factory :group_link do
    group nil
    linked nil

    trait :anime do
      linked { FactoryGirl.create :anime }
    end

    trait :manga do
      linked { FactoryGirl.create :manga }
    end

    trait :character do
      linked { FactoryGirl.create :character }
    end
  end
end

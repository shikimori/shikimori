FactoryGirl.define do
  factory :user_rate do
    status :planned
    target { FactoryGirl.create(:anime) }
    user
    episodes 0
    volumes 0
    chapters 0

    trait :planned do
      status :planned
    end
    trait :watching do
      status :watching
    end
    trait :completed do
      status :completed
    end
    trait :on_hold do
      status :on_hold
    end
    trait :dropped do
      status :dropped
    end
  end
end

FactoryGirl.define do
  factory :user_rate do
    status UserRateStatus.get UserRateStatus::Planned
    target { FactoryGirl.create(:anime) }
    user { FactoryGirl.create(:user) }
    episodes 0
    volumes 0
    chapters 0

    trait :planned do
      status UserRateStatus.get UserRateStatus::Planned
    end
    trait :watching do
      status UserRateStatus.get UserRateStatus::Watching
    end
    trait :completed do
      status UserRateStatus.get UserRateStatus::Completed
    end
    trait :on_hold do
      status UserRateStatus.get UserRateStatus::OnHold
    end
    trait :dropped do
      status UserRateStatus.get UserRateStatus::Dropped
    end
  end
end

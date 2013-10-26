FactoryGirl.define do
  factory :user_rate do
    status UserRateStatus::Planned
    target { FactoryGirl.create(:anime) }
    user { FactoryGirl.create(:user) }
  end
end

FactoryGirl.define do
  factory :vote do
    voteable { FactoryGirl.create(:anime) }
    user { FactoryGirl.create(:user) }
  end
end

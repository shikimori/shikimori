FactoryGirl.define do
  factory :vote do
    user
    voteable { FactoryGirl.create(:anime) }
  end
end

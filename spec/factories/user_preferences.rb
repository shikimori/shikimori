FactoryGirl.define do
  factory :user_preferences do
    user
    profile_privacy :public
  end
end

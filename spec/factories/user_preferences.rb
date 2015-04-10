FactoryGirl.define do
  factory :user_preferences do
    user
    list_privacy :public
  end
end

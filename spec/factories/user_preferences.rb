FactoryGirl.define do
  factory :user_preferences do
    user { seed :user }
    list_privacy :public
  end
end

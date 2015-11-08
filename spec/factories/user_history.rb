FactoryGirl.define do
  factory :user_history do
    user { seed :user }
    target nil
    action nil
    value nil
  end
end

FactoryGirl.define do  factory :topic_ignore do
    user nil
topic nil
  end

  sequence :email do |n|
    "email#{n}@factory.com"
  end
end

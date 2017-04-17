FactoryGirl.define do
  factory :collection do
    name "MyString"
    user nil
  end
  sequence :email do |n|
    "email#{n}@factory.com"
  end
end

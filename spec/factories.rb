FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end
end

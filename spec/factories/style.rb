FactoryGirl.define do
  factory :style do
    owner { seed :user }
    name ''
    css ''
  end
end

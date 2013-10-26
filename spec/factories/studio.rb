FactoryGirl.define do
  factory :studio do
    sequence(:name) { |n| "studio_#{n}" }
  end
end

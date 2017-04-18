FactoryGirl.define do
  factory :collection do
    sequence(:name) { |n| "Collection #{n}" }
    user { seed :user }
    locale :ru
  end
end

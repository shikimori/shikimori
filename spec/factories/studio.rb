FactoryBot.define do
  factory :studio do
    sequence(:name) { |n| "studio_#{n}" }
    is_visible { false }
  end
end

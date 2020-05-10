FactoryBot.define do
  factory :studio do
    sequence(:name) { |n| "studio_#{n}" }
    is_visible { false }
    is_publisher { false }
    is_verified { false }
    desynced { [] }
  end
end

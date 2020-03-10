FactoryBot.define do
  factory :publisher do
    sequence(:name) { |n| "publisher_#{n}" }
    is_visible { false }
  end
end

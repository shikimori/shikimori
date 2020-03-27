FactoryBot.define do
  factory :publisher do
    sequence(:name) { |n| "publisher_#{n}" }
  end
end

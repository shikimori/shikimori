FactoryGirl.define do
  factory :genre do
    sequence(:name) { |n| "genre_#{n}" }
  end
end

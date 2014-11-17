FactoryGirl.define do
  factory :section do
    sequence(:name) { |n| "section_#{n}" }
    permalink :o
    position 0

    trait :offtopic do
      id (Random.rand * 100_000).to_i
      permalink 'o'
    end
  end
end

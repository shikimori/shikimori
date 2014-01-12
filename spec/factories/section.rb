FactoryGirl.define do
  factory :section do
    sequence(:name) { |n| "section_#{n}" }
    permalink :o
  end
end

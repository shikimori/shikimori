FactoryGirl.define do
  factory :cosplay_gallery do
    confirmed true
    deleted false
    sequence(:target) { |n| "character_#{n}" }
  end
end

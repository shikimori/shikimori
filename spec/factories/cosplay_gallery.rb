FactoryGirl.define do
  factory :cosplay_gallery do
    type 'CosplaySession'
    confirmed true
    deleted false
    sequence(:target) { |n| "character_#{n}" }
  end
end

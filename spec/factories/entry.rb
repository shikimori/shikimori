FactoryGirl.define do
  factory :entry do
    user { FactoryGirl.create(:user) }
    sequence(:title) { |n| "entry title #{n}" }
    sequence(:text) { |n| "entry text #{n}" }
    type 'Entry'
  end
end

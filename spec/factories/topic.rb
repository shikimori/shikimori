FactoryGirl.define do
  factory :topic do
    user { FactoryGirl.create(:user) }
    sequence(:title) { |n| "topic_#{n}" }
    sequence(:text) { |n| "topic_text_#{n}" }
  end
end

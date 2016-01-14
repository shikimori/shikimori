FactoryGirl.define do
  factory :entry do
    user { seed :user }
    forum { seed :offtopic_forum }
    sequence(:title) { |n| "entry title #{n}" }
    sequence(:body) { |n| "entry text #{n}" }
    type 'Entry'
  end
end

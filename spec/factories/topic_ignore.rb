FactoryGirl.define do
  factory :topic_ignore do
    user { seed :user }
    topic { seed :topic }
  end
end

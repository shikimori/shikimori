FactoryBot.define do
  factory :topic_ignore do
    user { seed :user }
    topic { seed :offtopic_topic }
  end
end

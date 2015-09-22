FactoryGirl.define do
  factory :topic do
    user { seed :user }
    section { seed :offtopic_section }
    sequence(:title) { |n| "topic_#{n}" }
    sequence(:text) { |n| "topic_text_#{n}" }

    factory :review_comment, class: 'ReviewComment' do
      type 'ReviewComment'
    end
  end
end

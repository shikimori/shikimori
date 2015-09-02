FactoryGirl.define do
  factory :webm_video do
    url 'http://html5demos.com/assets/dizzy.webm'
    state 'pending'

    trait :pending do
      state 'pending'
    end

    trait :processed do
      state 'processed'
    end

    trait :failed do
      state 'failed'
    end
  end
end

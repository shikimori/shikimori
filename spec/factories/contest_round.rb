FactoryGirl.define do
  factory :contest_round do
    contest
    number 1
    additional false

    trait :created do
      state 'created'
    end

    trait :started do
      state 'started'
    end

    trait :finished do
      state 'finished'
    end
  end
end

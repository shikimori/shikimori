FactoryGirl.define do
  factory :review do
    association :target, factory: :anime
    user { seed :user }

    text { 's' * Review::MINIMUM_LENGTH }
    overall 1
    storyline 1
    music 1
    characters 1
    animation 1

    locale :ru

    after :build do |review|
      review.stub :generate_topics
    end

    trait :with_topics do
      after :build do |club|
        club.unstub :generate_topics
      end
    end
  end
end

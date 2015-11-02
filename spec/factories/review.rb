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
  end
end

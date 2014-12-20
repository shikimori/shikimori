FactoryGirl.define do
  factory :review do
    association :target, factory: :anime
    user

    text 1188.times.sum {|v| 's' }
    overall 1
    storyline 1
    music 1
    characters 1
    animation 1
  end
end

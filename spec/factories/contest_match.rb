FactoryGirl.define do
  factory :contest_match do
    left factory: :anime
    right factory: :anime
    round factory: :contest_round

    trait :finished do
      state 'finished'
    end

    trait :no_round do
      round nil
    end
  end
end

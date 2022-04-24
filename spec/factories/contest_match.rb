FactoryBot.define do
  factory :contest_match do
    left factory: :anime
    right factory: :anime
    round factory: :contest_round

    ContestMatch.aasm.states.map(&:name).each do |value|
      trait(value.to_sym) { state { value } }
    end

    trait :no_round do
      round { nil }
    end
  end
end

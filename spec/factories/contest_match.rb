FactoryBot.define do
  factory :contest_match do
    left factory: :anime
    right factory: :anime
    round factory: :contest_round

    # ContestMatch.state_machine.states.map(&:value).each do |contest_match_state|
    #   trait(contest_match_state.to_sym) { state { contest_match_state } }
    # end

    trait :no_round do
      round { nil }
    end
  end
end

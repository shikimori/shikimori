FactoryBot.define do
  factory :contest_round do
    contest
    number { 1 }
    additional { false }

    # ContestRound.state_machine.states.map(&:value).each do |contest_round_state|
    #   trait(contest_round_state.to_sym) { state { contest_round_state } }
    # end
  end
end

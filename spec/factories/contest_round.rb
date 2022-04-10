FactoryBot.define do
  factory :contest_round do
    contest
    number { 1 }
    additional { false }

    # ContestRound.aasm.states.map(&:name).each do |value|
    #   trait(value.to_sym) { state { value } }
    # end
  end
end

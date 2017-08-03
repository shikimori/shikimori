FactoryGirl.define do
  factory :poll do
    user { seed :user }
    state :pending

    Poll.state_machine.states.map(&:value).each do |poll_state|
      trait(poll_state.to_sym) { state poll_state }
    end
  end
end

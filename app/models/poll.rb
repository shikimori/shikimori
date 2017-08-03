class Poll < ApplicationRecord
  belongs_to :user

  validates :user, presence: true

  state_machine :state, initial: :pending do
    state :pending
    state :started
    state :stopped

    event(:start) { transition pending: :started }
    event(:stop) { transition started: :stopped }
  end
end

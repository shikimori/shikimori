class Poll < ApplicationRecord
  belongs_to :user

  validates :user, presence: true

  state_machine :state, initial: :pending do
    state :pending
    state :started

    event(:start) { transition pending: :started }
  end
end

class Poll < ApplicationRecord
  include Translation

  belongs_to :user
  has_many :poll_variants, dependent: :destroy

  validates :user, presence: true

  state_machine :state, initial: :pending do
    state :pending
    state :started
    state :stopped

    event(:start) { transition pending: :started }
    event(:stop) { transition started: :stopped }
  end

  accepts_nested_attributes_for :poll_variants

  def name
    i18n_t 'name', id: id
  end
end

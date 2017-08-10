class Poll < ApplicationRecord
  include Translation

  belongs_to :user
  has_many :poll_variants, dependent: :destroy

  validates :user, presence: true

  state_machine :state, initial: :pending do
    state :pending
    state :started
    state :stopped

    event(:start) do
      transition pending: :started, if: lambda { |poll|
        poll.persisted? && poll.poll_variants.size > 1
      }
    end
    event(:stop) { transition started: :stopped }
  end

  accepts_nested_attributes_for :poll_variants

  def name
    return super if super.present? || new_record?

    i18n_t 'name', id: id
  end

  def bb_code
    "[poll=#{id}]" unless pending?
  end
end

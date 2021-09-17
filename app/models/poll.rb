class Poll < ApplicationRecord
  acts_as_votable

  include Translation

  belongs_to :user
  has_many :variants, -> { order :id },
    class_name: 'PollVariant',
    inverse_of: :poll,
    dependent: :destroy

  enumerize :width,
    in: Types::Poll::Width.values,
    predicates: true

  validates :user, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :text, length: { maximum: 10_000 }

  state_machine :state, initial: :pending do
    state :pending
    state :started
    state :stopped

    event(:start) do
      transition(
        pending: :started,
        if: ->(poll) { poll.persisted? && poll.variants.size > 1 }
      )
    end
    event(:stop) { transition started: :stopped }
  end

  accepts_nested_attributes_for :variants

  def name
    return super if super.present? || new_record?

    i18n_t 'name', id: id
  end

  def bb_code
    "[poll=#{id}]"
  end

  def text_html
    BbCodes::Text.call text
  end
end

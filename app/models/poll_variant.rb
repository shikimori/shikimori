class PollVariant < ApplicationRecord
  acts_as_votable

  belongs_to :poll, touch: true

  validates :text, presence: true

  def votes_percent
    (
      100.0 * cached_votes_total / poll.variants.sum(&:cached_votes_total)
    ).round(2)
  end
end

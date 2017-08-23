class PollVariant < ApplicationRecord
  acts_as_votable

  belongs_to :poll, touch: true

  validates :text, presence: true

  def votes_percent
    total_votes = poll.variants.sum(&:cached_votes_total)

    if total_votes.zero?
      0
    else
      (100.0 * cached_votes_total / total).round(2)
    end
  end
end

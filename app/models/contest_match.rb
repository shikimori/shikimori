# cached_votes_up - votes for left
# cached_votes_down - votes for right
# cached_votes_total - votes_for_right + votes_for_left + refrained_votes
class ContestMatch < ApplicationRecord
  include AASM

  acts_as_votable cacheable_strategy: :update_columns

  belongs_to :round, class_name: 'ContestRound', touch: true
  belongs_to :left, polymorphic: true, optional: true
  belongs_to :right, polymorphic: true, optional: true

  delegate :contest, :strategy, to: :round

  UNDEFINED = 'undefined variant'
  VOTABLE = {
    true => 'left',
    false => 'right',
    nil => 'abstain'
  }

  aasm column: 'state', create_scopes: false do
    state Types::ContestMatch::State[:created], initial: true
    state Types::ContestMatch::State[:started]
    state Types::ContestMatch::State[:finished]

    event :start do
      transitions(
        from: Types::ContestMatch::State[:created],
        to: Types::ContestMatch::State[:started],
        if: -> { started_on && started_on <= Time.zone.today }
      )
    end
    event :finish do
      transitions(
        from: Types::ContestMatch::State[:started],
        to: Types::ContestMatch::State[:finished],
        if: -> { finished_on && finished_on < Time.zone.today }
      )
    end
  end

  alias can_vote? started?

  def left_votes
    cached_votes_up
  end

  def right_votes
    cached_votes_down
  end

  def winner
    if winner_id == left_id
      left
    elsif winner_id == right_id
      right
    end
  end

  def loser
    if winner_id == left_id
      right
    elsif winner_id == right_id
      left
    end
  end

  def draw?
    finished? && !winner_id
  end
end

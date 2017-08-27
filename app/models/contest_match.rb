# cached_votes_up - votes for left
# cached_votes_down - votes for right
# cached_votes_total - votes_for_right + votes_for_left + refrained_votes
class ContestMatch < ApplicationRecord
  UNDEFINED = 'undefined variant'
  VOTABLE = {
    true: 'left',
    false: 'right',
    'abstain' => 'abstain'
  }

  acts_as_votable

  belongs_to :round, class_name: ContestRound.name, touch: true
  belongs_to :left, polymorphic: true
  belongs_to :right, polymorphic: true

  has_many :contest_user_votes, dependent: :destroy

  delegate :contest, :strategy, to: :round

  # rubocop:disable Style/HashSyntax
  state_machine :state, initial: :created do
    state :created
    state :started
      # # обновление статуса пользоваетля в зависимости от возможности голосовать далее
      # def update_user(user, ip)
        # if round.matches.with_user_vote(user, ip).select(&:started?).all?(&:voted?)
          # user.update_attribute round.contest.user_vote_key, false
        # end
      # end
    state :finished

    event :start do
      transition :created => :started, if: lambda { |match|
        match.started_on && match.started_on <= Time.zone.today
      }
    end
    event :finish do
      transition :started => :finished, if: lambda { |match|
        match.finished_on && match.finished_on < Time.zone.today
      }
    end
  end
  # rubocop:enable Style/HashSyntax

  alias can_vote? started?

  def left_votes
    cached_votes_up
  end

  def right_votes
    cached_votes_down
  end

  # за какой вариант проголосовал пользователь
  # def voted_for
    # if voted_id && voted_id.zero?
      # :none
    # elsif voted_id == right_id && voted_id.nil?
      # :auto
    # elsif voted_id == left_id
      # :left
    # elsif voted_id == right_id
      # :right
    # else
      # nil
    # end
  # end

  # победитель
  def winner
    if winner_id == left_id
      left
    else
      right
    end
  end

  # проигравший
  def loser
    if winner_id == left_id
      right
    else
      left
    end
  end
end

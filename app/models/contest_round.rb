class ContestRound < ApplicationRecord
  include AASM
  include Translation

  S = 'S' # staring group
  W = 'W' # winners group
  L = 'L' # losers group
  F = 'F' # final group

  belongs_to :contest, touch: true
  has_many :matches, -> { order :id },
    class_name: 'ContestMatch',
    inverse_of: :round,
    foreign_key: :round_id,
    dependent: :destroy

  delegate :strategy, to: :contest

  aasm column: 'state', create_scopes: false do
    state :created, initial: true
    state :started
    state :finished

    event :start do
      transitions from: :created,
        to: :started,
        if: -> { matches.any? }
    end
    event :finish do
      transitions form: :started,
        to: :finished,
        if: -> {
          matches.any? && matches.all? { |v| v.finished? || v.may_finish? }
        }
    end
  end

  def title_ru is_short = false
    title is_short, Types::Locale[:ru]
  end

  def title_en is_short = false
    title is_short, Types::Locale[:en]
  end

  def title is_short = false, locale = nil
    return "#{number}#{'a' if additional}" if is_short

    i18n_t(
      'title',
      number: number,
      additional: ('a' if additional),
      locale: locale
    )
  end

  def to_param
    "#{number}#{'a' if additional}"
  end

  def prior_round
    @prior_round ||= begin
      index = contest.rounds.index self

      if index.zero?
        nil
      else
        contest.rounds[index - 1]
      end
    end
  end

  def next_round
    @next_round ||= begin
      index = contest.rounds.index self

      if index == contest.rounds.size - 1
        nil
      else
        contest.rounds[index + 1]
      end
    end
  end

  def first?
    prior_round.nil?
  end

  def last?
    next_round.nil?
  end
end

class ContestRound < ApplicationRecord
  include Translation

  # стартовая группа
  S = 'S'
  # ни разу не проигравшая группа
  W = 'W'
  # один раз проигравшая группа
  L = 'L'
  # финальная группа
  F = 'F'

  belongs_to :contest, touch: true
  has_many :matches, -> { order :id },
    class_name: ContestMatch.name,
    inverse_of: :round,
    foreign_key: :round_id,
    dependent: :destroy

  delegate :strategy, to: :contest

  # state_machine :state, initial: :created do
  #   state :started
  #   state :finished
  # 
  #   event :start do
  #     transition :created => :started, if: ->(round) { round.matches.any? }
  #   end
  #   event :finish do
  #     transition :started => :finished,
  #       if: ->(round) { round.matches.all? { |v| v.finished? || v.can_finish? } }
  #   end
  # end

  def title_ru is_short = false
    title is_short, Types::Locale[:ru]
  end

  def title_en is_short = false
    title is_short, Types::Locale[:en]
  end

  # название раунда
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

  # предыдущий раунд
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

  # следующий раунд
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

  # первый ли это раунд?
  def first?
    prior_round.nil?
  end

  # последний ли это раунд?
  def last?
    next_round.nil?
  end
end

class ContestRound < ActiveRecord::Base
  # стартовая группа
  S = 'S'
  # ни разу не проигравшая группа
  W = 'W'
  # один раз проигравшая группа
  L = 'L'
  # финальная группа
  F = 'F'

  belongs_to :contest, touch: true
  has_many :matches,
    class_name: ContestMatch.name,
    foreign_key: :round_id,
    dependent: :destroy

  attr_accessible :number, :additional

  state_machine :state, initial: :created do
    state :started
    state :finished

    event :start do
      transition created: :started, if: lambda { |round| round.matches.any? }
    end
    event :finish do
      transition started: :finished, if: lambda { |round| round.matches.all? { |v| v.finished? || v.can_finish? } }
    end

    after_transition created: :started do |round, transition|
      round.matches.select {|v| v.started_on <= Date.today }.each(&:start!)
    end

    before_transition started: :finished do |round, transition|
      round.matches.select(&:started?).each(&:finish!)
    end

    after_transition started: :finished do |round, transition|
      if round.next_round
        round.next_round.start!
        round.strategy.advance_members round.next_round, round
      else
        round.contest.finish!
      end
    end
  end

  # название раунда
  def title(short=false)
    "#{short ? '' : 'Раунд '}#{number}#{'a' if additional}"
  end

  def to_param
    "#{number}#{'a' if additional}"
  end

  # предыдущий раунд
  def prior_round
    @prior_round ||= begin
      index = contest.rounds.index self
      if index == 0
        nil
      else
        contest.rounds[index-1]
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
        contest.rounds[index+1]
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

  # стратегия турнира
  def strategy
    contest.strategy
  end
end

# frozen_string_literal: true

# TODO: refactor fat model
class Contest < ApplicationRecord
  include TopicsConcern

  MINIMUM_MEMBERS = 5
  MAXIMUM_MEMBERS = 196

  enumerize :member_type,
    in: Types::Contest::MemberType.values,
    predicates: true
  enumerize :strategy_type,
    in: Types::Contest::StrategyType.values,
    predicates: true
  enumerize :user_vote_key, in: Types::Contest::UserVoteKey.values

  belongs_to :user

  has_many :links,
    class_name: ContestLink.name,
    dependent: :destroy

  has_many :rounds, -> { order [:number, :additional, :id] },
    class_name: ContestRound.name,
    inverse_of: :contest,
    dependent: :destroy

  has_many :winners, -> { order :position },
    class_name: ContestWinner.name,
    inverse_of: :contest,
    dependent: :destroy

  validates :title_ru, :title_en, presence: true
  validates :user, :started_on, :user_vote_key, :strategy_type,
    :member_type, presence: true
  validates :matches_interval, :match_duration, :matches_per_round,
    numericality: { greater_than: 0 }, presence: true

  has_many :animes, -> { order :name },
    through: :links,
    source: :linked,
    source_type: Anime.name

  has_many :characters, -> { order :name },
    through: :links,
    source: :linked,
    source_type: Character.name

  has_many :suggestions,
    class_name: ContestSuggestion.name,
    dependent: :destroy

  delegate :total_rounds, :results, to: :strategy

  state_machine :state, initial: :created do
    state :created, :proposing

    state :proposing
    state :started
    state :finished

    event(:propose) { transition created: :proposing }
    event(:stop_propose) { transition proposing: :created }
    event :start do
      transition [:created, :proposing] => :started,
        if: lambda { |contest| contest.links.count >= MINIMUM_MEMBERS && contest.links.count <= MAXIMUM_MEMBERS } # && Contest.all.none?(&:started?)
    end
    event(:finish) { transition started: :finished }

    after_transition :created => [:proposing, :started] do |contest, transition|
      contest.generate_topics Site::DOMAIN_LOCALES
    end
  end

  class << self
    # текущий опрос
    def current
      Contest
        .where(
          "state in ('proposing', 'started') or
          (state = 'finished' and finished_on >= ?)",
          1.week.ago
        )
        .order(:started_on)
        .to_a
    end
  end

  # текущий раунд
  def current_round
    if finished?
      rounds.last
    else
      rounds.select(&:started?).first ||
        rounds.select { |v| !v.finished? }.first ||
        rounds.first
    end
  end

  # побежденные аниме данным аниме
  def defeated_by entry, round
    @defeated ||= {}
    @defeated["#{entry.id}-#{round.id}"] ||= ContestMatch
      .where(
        round_id: rounds.map(&:id).select { |v| v <= round.id },
        state: 'finished',
        winner_id: entry.id
      )
      .includes(:left, :right)
      .order(:id)
      .map { |vote| vote.winner_id == vote.left_id ? vote.right : vote.left }
      .compact
  end

  def to_param
    "#{self.id}-#{name.permalinked}"
  end

  def title
    I18n.russian? ? title_ru : title_en
  end

  # for compatibility with forum
  def name
    title
  end

  # стратегия создания раундов
  def strategy
    @strategy ||= if double_elimination?
      Contest::DoubleEliminationStrategy.new self
    elsif play_off?
      Contest::PlayOffStrategy.new self
    else
      Contest::SwissStrategy.new self
    end
  end

  # участники контеста
  def members
    anime? ? animes : characters
  end

  # класс участника контеста
  def member_klass
    member_type.classify.constantize
  end

  def topic_user
    user
  end

  # for DbEntryDecorator
  def description_ru
    nil
  end

  # for DbEntryDecorator
  def description_en
    nil
  end
end

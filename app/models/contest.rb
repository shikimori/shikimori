class Contest < ActiveRecord::Base
  extend Enumerize
  include PermissionsPolicy

  MINIMUM_MEMBERS = 5
  MAXIMUM_MEMBERS = 128

  belongs_to :user

  attr_accessible :title, :description, :started_on, :phases, :matches_per_round, :match_duration, :matches_interval, :user_vote_key, :wave_days, :strategy_type, :suggestions_per_user, :member_type

  validates :title, :user, :started_on, :user_vote_key, :strategy_type, :member_type, presence: true
  validates :matches_interval, :match_duration, :matches_per_round, numericality: { greater_than: 0 }, presence: true

  enumerize :member_type, in: [:anime, :character], predicates: true
  enumerize :strategy_type, in: [:double_elimination, :play_off, :swiss], predicates: true
  delegate :total_rounds, :results, to: :strategy

  has_many :links,
    class_name: ContestLink.name,
    dependent: :destroy

  has_many :rounds,
    class_name: ContestRound.name,
    order: [:number, :additional],
    dependent: :destroy

  has_one :thread,
    class_name: ContestComment.name,
    foreign_key: :linked_id,
    conditions: { linked_type: name },
    dependent: :destroy

private
  has_many :animes,
    through: :links,
    source: :linked,
    source_type: Anime.name,
    order: :name

  has_many :characters,
    through: :links,
    source: :linked,
    source_type: Character.name,
    order: :name

public
  has_many :suggestions, class_name: ContestSuggestion.name, dependent: :destroy

  before_save :update_permalink
  after_save :sync_thread

  state_machine :state, initial: :created do
    state :created, :proposing do
      # подготовка голосования к запуску
      def prepare
        rounds.destroy_all
        strategy.create_rounds
        update_attribute :updated_at, DateTime.now
      end
    end
    state :started
    state :finished
    event :propose do
      transition [:created] => :proposing
    end
    event :start do
      transition [:created, :proposing] => :started, :if => lambda { |contest| contest.links.count >= MINIMUM_MEMBERS && contest.links.count <= MAXIMUM_MEMBERS } # && Contest.all.none?(&:started?)
    end
    event :finish do
      transition started: :finished
    end

    after_transition created: [:proposing, :started] do |contest, transition|
      contest.send :create_thread unless contest.thread
    end

    before_transition [:created, :proposing] => :started do |contest, transition|
      contest.update_attribute :started_on, Date.today if contest.started_on < Date.today
      if contest.rounds.empty? || contest.rounds.any? { |v| v.matches.any? { |v| v.started_on < Date.today } }
        contest.prepare
      end
    end
    after_transition [:created, :proposing] => :started do |contest, transition|
      contest.rounds.first.start!
    end

    after_transition started: :finished do |contest, transition|
      contest.update_attribute :finished_on, Date.today
      User.update_all contest.user_vote_key => false
    end
  end

  class << self
    # текущий опрос
    def current
      Contest
          .where { state.eq('proposing') | state.eq('started') | (state.eq('finished') & finished_on.gte(DateTime.now - 1.week)) }
          .order(:started_on)
          .all
    end
  end

  # текущий раунд
  def current_round
    if finished?
      rounds.last
    else
      rounds.select(&:started?).first || rounds.select { |v| !v.finished? }.first || rounds.first
    end
  end

  # наступил следующий день. обновление состояний голосований
  def process!
    started = current_round.matches.select(&:can_start?).each(&:start!)
    finished = current_round.matches.select(&:can_finish?).each(&:finish!)
    round = current_round.finish! if current_round.can_finish?

    update_attribute :updated_at, DateTime.now if started.any? || finished.any? || round
  end

  # побежденные аниме данным аниме
  def defeated_by entry, round
    @defeated ||= {}
    @defeated["#{entry.id}-#{round.id}"] ||= ContestMatch
        .where(round_id: rounds.map(&:id).select {|v| v <= round.id })
        .where(state: 'finished')
        .where(winner_id: entry.id)
        .includes(:left, :right)
        .map { |vote|
          if vote.winner_id == vote.left_id
            vote.right
          else
            vote.left
          end
        }.compact
  end

  # для урлов
  def to_param
    "#{self.id}-#{self.permalink}"
  end

  # для совместимости с форумом
  def name
    title
  end

  # ключ в модели пользователя для хранении статуса проголосованности опроса
  def user_vote_key
    case self[:user_vote_key].to_s
      when 'can_vote_1' then 'can_vote_1'
      when 'can_vote_2' then 'can_vote_2'
      when 'can_vote_3' then 'can_vote_3'
    end
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

private
  def update_permalink
    self.permalink = title.permalinked if changes.include? :title
  end

  def sync_thread
    thread.update_attribute(:title, title) if thread && thread.title != title
  end

  # создание AniMangaComment для элемента сразу после создания
  def create_thread
    ContestComment.create! linked: self, section_id: Section::ContestsId, user: user
  end
end

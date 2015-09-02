class Contest < ActiveRecord::Base
  MINIMUM_MEMBERS = 5
  MAXIMUM_MEMBERS = 196

  belongs_to :user

  validates :title, :user, :started_on, :user_vote_key, :strategy_type, :member_type,
    presence: true
  validates :matches_interval, :match_duration, :matches_per_round,
    numericality: { greater_than: 0 }, presence: true

  enumerize :member_type, in: [:anime, :character], predicates: true
  enumerize :strategy_type, in: [:double_elimination, :play_off, :swiss], predicates: true
  delegate :total_rounds, :results, to: :strategy

  has_many :links,
    class_name: ContestLink.name,
    dependent: :destroy

  has_many :rounds, -> { order [:number, :additional, :id] },
    class_name: ContestRound.name,
    dependent: :destroy

  has_one :thread, -> { where linked_type: Contest.name },
    class_name: ContestComment.name,
    foreign_key: :linked_id,
    dependent: :destroy

private

  has_many :animes, -> { order :name },
    through: :links,
    source: :linked,
    source_type: Anime.name

  has_many :characters, -> { order :name },
    through: :links,
    source: :linked,
    source_type: Character.name

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

    state :proposing do
      # очистка голосов от накруток
      def cleanup_suggestions!
        suggestions
          .joins(:user)
          .merge(User.suspicious)
          .destroy_all
      end
    end
    state :started
    state :finished

    event(:propose) { transition created: :proposing }
    event(:stop_propose) { transition proposing: :created }
    event :start do
      transition [:created, :proposing] => :started, :if => lambda { |contest| contest.links.count >= MINIMUM_MEMBERS && contest.links.count <= MAXIMUM_MEMBERS } # && Contest.all.none?(&:started?)
    end
    event(:finish) { transition started: :finished }

    after_transition created: [:proposing, :started] do |contest, transition|
      contest.send :generate_thread unless contest.thread
    end
    before_transition [:created, :proposing] => :started do |contest, transition|
      contest.update_attribute :started_on, Time.zone.today if contest.started_on < Time.zone.today
      if contest.rounds.empty? || contest.rounds.any? { |v| v.matches.any? { |v| v.started_on < Time.zone.today } }
        contest.prepare
      end
    end
    after_transition [:created, :proposing] => :started do |contest, transition|
      contest.rounds.first.start!
    end
    after_transition started: :finished do |contest, transition|
      FinalizeContest.perform_async contest.id
    end
  end

  class << self
    # текущий опрос
    def current
      Contest
        .where("state in ('proposing', 'started') or (state = 'finished' and finished_on >= ?)", Time.zone.now - 1.week)
        .order(:started_on)
        .to_a
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
  def progress!
    started = current_round.matches.select(&:can_start?).each(&:start!)
    finished = current_round.matches.select(&:can_finish?).each(&:finish!)
    round = current_round.finish! if current_round.can_finish?

    update_attribute :updated_at, DateTime.now if started.any? || finished.any? || round
  end

  # побежденные аниме данным аниме
  def defeated_by entry, round
    @defeated ||= {}
    @defeated["#{entry.id}-#{round.id}"] ||= ContestMatch
      .where(
        round_id: rounds.map(&:id).select {|v| v <= round.id },
        state: 'finished',
        winner_id: entry.id
      )
      .includes(:left, :right)
      .order(:id)
      .map { |vote| vote.winner_id == vote.left_id ? vote.right : vote.left }
      .compact
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
  def generate_thread
    create_thread! linked: self, section_id: Section::CONTESTS_ID, user: user
  end
end

class UserRate < ApplicationRecord
  # максимальное значение эпизодов/частей
  MAXIMUM_EPISODES = 10_000
  MAXIMUM_SCORE = 10

  MAXIMUM_TEXT_SIZE = 4096

  enum status: {
    planned: 0,
    watching: 1,
    rewatching: 9,
    completed: 2,
    on_hold: 3,
    dropped: 4
  }

  class << self
    attr_accessor :is_skip_logging

    def wo_logging
      old = @is_skip_logging
      @is_skip_logging = true

      begin
        yield
      ensure
        @is_skip_logging = old
      end
    end

    def skip_logging?
      !!@is_skip_logging
    end
  end

  delegate :skip_logging?, to: :class

  belongs_to :target, polymorphic: true
  belongs_to :anime,
    class_name: 'Anime',
    foreign_key: :target_id,
    inverse_of: :rates,
    optional: true
  belongs_to :manga,
    class_name: 'Manga',
    foreign_key: :target_id,
    inverse_of: :rates,
    optional: true

  belongs_to :user,
    touch: Rails.env.test? ? false : :rate_at

  before_save :smart_process_changes
  before_save :log_changed, if: -> { !skip_logging? && persisted? && changes.any? }
  after_create :log_created, unless: :skip_logging?

  after_destroy :log_deleted, unless: :skip_logging?

  validates :target, :user, :status, presence: true
  validates :user_id, uniqueness: { scope: %i[target_id target_type] }
  validates :text, length: { maximum: MAXIMUM_TEXT_SIZE }

  def text= value
    if !value || value.size <= MAXIMUM_TEXT_SIZE
      super
    else
      super value[0..MAXIMUM_TEXT_SIZE - 1]
    end
  end

  def anime?
    target_type == 'Anime'
  end

  def manga?
    target_type == 'Manga'
  end

  def text_html
    BbCodes::CachedText.call text
  end

  def status= new_status
    new_status.is_a?(String) && new_status =~ /^\d$/ ?
      super(new_status.to_i) :
      super
  end

  def self.status_name status, target_type
    status_name =
      if status.is_a? Integer
        (
          statuses.find { |_k, v| v == status } ||
          raise("unknown status #{status} #{target_type}")
        ).first
      else
        status
      end

    I18n.t 'activerecord.attributes.user_rate.statuses.'\
      "#{target_type.downcase}.#{status_name}"
  end

  def self.status_id status
    status_string = status.to_s
    statuses.find { |k, _v| k == status_string }.second
  end

  def status_name
    self.class.status_name status, target_type
  end

  def target
    if target_type == Anime.name
      association(:anime).loaded? && !anime.nil? ? anime : super
    else
      association(:manga).loaded? && !manga.nil? ? manga : super
    end
  end

private

  # перед сохранением модели, смотрим, что изменилось,
  # соответствующе меняем остальные поля и заносим запись в историю
  def smart_process_changes
    self.rewatches ||= 0

    anime_status_changed if changes['status'] && anime?
    manga_status_changed if changes['status'] && manga?

    score_changed if changes['score']

    counter_changed 'episodes' if changes['episodes'] && anime?
    counter_changed 'chapters' if changes['chapters'] && manga?
    counter_changed 'volumes' if changes['volumes'] && manga?
  end

  # логика обновления полей при выставлении статусов
  def anime_status_changed
    if completed?
      self.episodes = target.episodes unless target.episodes.zero?
    end

    if rewatching?
      self.episodes = 0 if !changes['episodes'] || changes['episodes'].first.blank?
    end
  end

  def manga_status_changed
    if completed?
      self.volumes = target.volumes unless target.volumes.zero?
      self.chapters = target.chapters unless target.chapters.zero?
    end

    if rewatching?
      self.volumes = 0 if !changes['volumes'] || changes['volumes'].first.blank?
      self.chapters = 0 if !changes['chapters'] || changes['chapters'].first.blank?
    end
  end

  # логика обновления полей при выставлении оценки
  def score_changed
    self.score = 0 if score.blank?

    self.score = changes['score'].first if score > MAXIMUM_SCORE || score.negative?
  end

  # логика обновления полей при выставлении числа эпизодов
  def counter_changed counter
    # указали nil или меньше нуля - сбрасываем на ноль
    self[counter] = 0 if self[counter].blank? || self[counter].negative?
    # указали больше эпизодов, чем есть в аниме - сбрасываем на число эпизодов в аниме
    self[counter] = target[counter] if self[counter] > target[counter] && !target[counter].zero?
    # указали какую-то нереальную цифру - сбрасываем на число эпизодов в аниме
    self[counter] = changes[counter].first if self[counter] > MAXIMUM_EPISODES

    # сбросили главы - сбрасываем и тома
    self.chapters = 0 if counter == 'volumes' && volumes.zero?
    # и наоборот
    self.volumes = 0 if counter == 'chapters' && chapters.zero?

    # указали число эпизодов равным числу эпиздов в аниме - помечаем просмотренным
    if self[counter] == target[counter] && self[counter].positive? && changes['status'].nil?
      self.rewatches += 1 if rewatching?
      self.status = :completed

      # для манги устанавливаем в максимум второй счётчик
      self.chapters = target.chapters if counter == 'volumes'
      self.volumes = target.volumes if counter == 'chapters'
    end

    if persisted? && changes[counter]
      # перевели с нуля на какую-то цифру - помечаем, что начали смотреть
      if self[counter].positive? && (changes[counter].first || 0).zero?
        self.status = :watching if changes['status'].nil? && !rewatching? && !completed? && !dropped?
      end

      # перевели с какой-то цифры в ноль - помечаем, что перенесли в запланированное
      if self[counter].zero? && changes[counter] &&
          !(changes[counter].first || 0).zero?
        self.status = :planned if changes['status'].nil? && !rewatching?
      end
    end
  end

  # запись в историю о занесении в список
  def log_created
    UserHistory.add user, target, UserHistoryAction::ADD

    unless planned?
      UserHistory.add(
        user,
        target,
        UserHistoryAction::STATUS,
        UserRate.statuses[status]
      )
    end

    unless score.zero?
      UserHistory.add(
        user,
        target,
        UserHistoryAction::RATE,
        score
      )
    end
  end

  # запись в историю об изменении стутса
  def log_changed
    if changes['status']
      UserHistory.add(
        user,
        target,
        UserHistoryAction::STATUS,
        UserRate.statuses[changes['status'].second],
        UserRate.statuses[changes['status'].first]
      )
    end

    if (
        (anime? && changes['episodes']) ||
        (manga? && changes['volumes']) ||
        (manga? && changes['chapters'])
      ) && (!changes['status'] || changes['status'] == %w[planned watching])

      counter =
        if anime?
          'episodes'
        elsif changes['volumes']
          'volumes'
        elsif changes['chapters']
          'chapters'
        end

      UserHistory.add(
        user,
        target,
        UserHistoryAction.const_get(counter.upcase),
        self[counter],
        changes[counter].first
      )
    end

    if changes['score']
      UserHistory.add(
        user,
        target,
        UserHistoryAction::RATE,
        score,
        changes['score'].first
      )
    end
  end

  # запись в историю об удалении из списка
  def log_deleted
    UserHistory.add user, target, UserHistoryAction::DELETE
  end
end

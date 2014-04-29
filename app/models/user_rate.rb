# аниме и манга в списке пользователя
# TODO: переделать status в enumerize (https://github.com/brainspec/enumerize)
# TODO: вместо переделки на enumerize, после апгрейда на rails 4.1, подумать о переходе на activerecord enum
class UserRate < ActiveRecord::Base
  # максимальное значение эпизодов/частей
  MAXIMUM_EPISODES = 2000
  MAXIMUM_SCORE = 10

  belongs_to :target, polymorphic: true
  belongs_to :anime, class_name: Anime.name, foreign_key: :target_id
  belongs_to :manga, class_name: Manga.name, foreign_key: :target_id

  belongs_to :user, touch: true

  before_save :smart_process_changes
  before_save :check_data
  before_save :log_changed, if: -> { persisted? && changes.any? }
  after_create :log_created

  after_destroy :log_deleted

  validates :target, :user, presence: true

  def anime?
    target_type == 'Anime'
  end

  def manga?
    target_type == 'Manga'
  end

  def planned?
    status == UserRateStatus.get(UserRateStatus::Planned)
  end

  def watching?
    status == UserRateStatus.get(UserRateStatus::Watching)
  end

  def completed?
    status == UserRateStatus.get(UserRateStatus::Completed)
  end

  def on_hold?
    status == UserRateStatus.get(UserRateStatus::OnHold)
  end

  def dropped?
    status == UserRateStatus.get(UserRateStatus::Dropped)
  end

  def notice_html
    notice.present? ? BbCodeFormatter.instance.format_comment(notice) : notice
  end

private
  # перед сохранением модели, смотрим, что изменилось, и соответствующе меняем остальные поля, и заносим запись в историю
  def smart_process_changes
    status_changed if changes['status']
    score_changed if changes['score']

    counter_changed 'episodes' if changes['episodes'] && anime?
    counter_changed 'chapters' if changes['chapters'] && manga?
    counter_changed 'volumes' if changes['volumes'] && manga?
  end

  # логика обновления полей при выставлении статусов
  def status_changed
    self.episodes = target.episodes if anime? && completed?
    self.volumes = target.volumes if manga? && completed?
    self.chapters = target.chapters if manga? && completed?
  end

  # логика обновления полей при выставлении оценки
  def score_changed
    self.score = changes['score'].first if score > MAXIMUM_SCORE || score < 0
  end

  # логика обновления полей при выставлении числа эпизодов
  def counter_changed counter
    # указали больше эпизодов, чем есть в аниме - сбрасываем на число эпизодов в аниме
    self[counter] = target[counter] if self[counter] > target[counter] && !target[counter].zero?
    # указали какую-то нереальную цифру - сбрасываем на число эпизодов в аниме
    self[counter] = changes[counter].first if self[counter] > MAXIMUM_EPISODES
    # указали меньше нуля - сбрасываем на ноль
    self[counter] = 0 if self[counter] < 0

    # сбросили главы - сбрасываем и тома
    self.chapters = 0 if counter == 'volumes' && self.volumes.zero?
    # и наоборот
    self.volumes = 0 if counter == 'chapters' && self.chapters.zero?

    if changes[counter]
      # перевели с нуля на какую-то цифру - помечаем, что начали смотреть
      if self[counter] > 0 && changes[counter].first.zero?
        self.status = UserRateStatus.get UserRateStatus::Watching
      end

      # перевели с какой-то цифры в ноль - помечаем, что перенесли в запланированное
      if self[counter].zero? && changes[counter] && changes[counter].first > 0
        self.status = UserRateStatus.get UserRateStatus::Planned
      end
    end

    # указали число эпизодов, равно числу эпиздов в аниме - помечаем просмотренным
    if self[counter] == target[counter] && self[counter] > 0
      self.status = UserRateStatus.get UserRateStatus::Completed

      # для манги устанавливаем в максимум второй счётчик
      self.chapters = target.chapters if counter == 'volumes'
      self.volumes = target.volumes if counter == 'chapters'
    end
  end

  # запись в историю о занесении в список
  def log_created
    UserHistory.add user, target, UserHistoryAction::Add
  end

  # запись в историю об изменении стутса
  def log_changed
    if changes['status']
      UserHistory.add user, target, UserHistoryAction::Status, status, changes['status'].first

    elsif changes['episodes'] || changes['volumes'] || changes['chapters']
      counter = if anime?
        'episodes'
      elsif changes['volumes']
        'volumes'
      elsif changes['chapters']
        'chapters'
      end

      UserHistory.add user, target, UserHistoryAction.const_get(counter.capitalize), self[counter], changes[counter].first
    end

    if changes['score']
      UserHistory.add user, target, UserHistoryAction::Rate, score, changes['score'].first
    end
  end

  # запись в историю об удалении из списка
  def log_deleted
    UserHistory.add user, target, UserHistoryAction::Delete
  end

  # валидации
  def check_data
    unless UserRateStatus.contains(status)
      self.errors[:status] = 'некорректный статус'
      return false
    end
  end
end

# аниме и манга в списке пользователя
# TODO: переделать status в enumerize (https://github.com/brainspec/enumerize)
# TODO: вместо переделки на enumerize, после апгрейда на rails 4.1, подумать о переходе на activerecord enum
class UserRate < ActiveRecord::Base
  # максимальное значение эпизодов/частей
  MAXIMUM_EPISODES = 2000
  MAXIMUM_SCORE = 10

  enum status: { planned: 0, watching: 1, completed: 2, rewatching: 9, on_hold: 3, dropped: 4 }

  belongs_to :target, polymorphic: true
  belongs_to :anime, class_name: Anime.name, foreign_key: :target_id
  belongs_to :manga, class_name: Manga.name, foreign_key: :target_id

  belongs_to :user, touch: true

  before_save :smart_process_changes
  before_save :log_changed, if: -> { persisted? && changes.any? }
  after_create :log_created

  after_destroy :log_deleted

  validates :target, :user, presence: true
  #validates :user_id, uniqueness: { scope: [:target_id, :target_type] }

  def self.create_or_find user_id, target_id, target_type
    UserRate.where(user_id: user_id, target_id: target_id, target_type: target_type).first ||
      UserRate.create(user_id: user_id, target_id: target_id, target_type: target_type, status: :planned)
  end

  def anime?
    target_type == 'Anime'
  end

  def manga?
    target_type == 'Manga'
  end

  def text_html
    text.present? ? BbCodeFormatter.instance.format_comment(text) : text
  end

  def status= new_status
    new_status.kind_of?(String) && new_status =~ /^\d$/ ? super(new_status.to_i) : super
  end

  def self.status_name status, target_type
    status_name = status.kind_of?(Integer) ? statuses.find {|k,v| v == status }.first : status
    I18n.t "activerecord.attributes.user_rate.statuses.#{target_type.downcase}.#{status_name}"
  end

  def self.status_id status
    status_string = status.to_s
    statuses.find {|k,v| k == status_string }.second
  end

  def status_name
    self.class.status_name status, target_type
  end

private
  # перед сохранением модели, смотрим, что изменилось, и соответствующе меняем остальные поля, и заносим запись в историю
  def smart_process_changes
    self.rewatches ||= 0
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

    self.episodes = 0 if anime? && rewatching? && (!changes['episodes'] || changes['episodes'].first.nil?)
    self.volumes = 0 if manga? && rewatching? && (!changes['volumes'] || changes['volumes'].first.nil?)
    self.chapters = 0 if manga? && rewatching? && (!changes['chapters'] || changes['chapters'].first.nil?)
  end

  # логика обновления полей при выставлении оценки
  def score_changed
    self.score = 0 if score.nil?
    self.score = changes['score'].first if score > MAXIMUM_SCORE || score < 0
  end

  # логика обновления полей при выставлении числа эпизодов
  def counter_changed counter
    # указали nil или меньше нуля - сбрасываем на ноль
    self[counter] = 0 if self[counter].nil? || self[counter] < 0
    # указали больше эпизодов, чем есть в аниме - сбрасываем на число эпизодов в аниме
    self[counter] = target[counter] if self[counter] > target[counter] && !target[counter].zero?
    # указали какую-то нереальную цифру - сбрасываем на число эпизодов в аниме
    self[counter] = changes[counter].first if self[counter] > MAXIMUM_EPISODES

    # сбросили главы - сбрасываем и тома
    self.chapters = 0 if counter == 'volumes' && self.volumes.zero?
    # и наоборот
    self.volumes = 0 if counter == 'chapters' && self.chapters.zero?

    # указали число эпизодов равным числу эпиздов в аниме - помечаем просмотренным
    if self[counter] == target[counter] && self[counter] > 0 && changes['status'].nil?
      self.rewatches += 1 if rewatching?
      self.status = :completed

      # для манги устанавливаем в максимум второй счётчик
      self.chapters = target.chapters if counter == 'volumes'
      self.volumes = target.volumes if counter == 'chapters'
    end

    if changes[counter]
      # перевели с нуля на какую-то цифру - помечаем, что начали смотреть
      if self[counter] > 0 && changes[counter].first.zero?
        if changes['status'].nil? && !rewatching?
          self.status = :watching
        end
      end

      # перевели с какой-то цифры в ноль - помечаем, что перенесли в запланированное
      if self[counter].zero? && changes[counter] && !changes[counter].first.zero?
        if changes['status'].nil? && !rewatching?
          self.status = :planned
        end
      end
    end
  end

  # запись в историю о занесении в список
  def log_created
    UserHistory.add user, target, UserHistoryAction::Add
  end

  # запись в историю об изменении стутса
  def log_changed
    if changes['status']
      UserHistory.add user, target, UserHistoryAction::Status, self[:status], UserRate.statuses[changes['status'].first]

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
end

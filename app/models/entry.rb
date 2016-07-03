class Entry < ActiveRecord::Base
  include Commentable

  NEWS_WALL = /[\r\n]*\[wall[\s\S]+\[\/wall\]\Z/

  belongs_to :forum
  belongs_to :linked, polymorphic: true
  belongs_to :user

  validates :forum, :user, presence: true

  has_many :messages,
    -> { where "linked_type = '#{self.class.name}' or linked_type = '#{Entry.name}'" },
    foreign_key: :linked_id,
    dependent: :delete_all

  has_many :topic_ignores,
    foreign_key: :topic_id,
    dependent: :destroy

  before_save :validates_linked

  # топики без топиков о выходе эпизодов
  scope :wo_episodes, -> {
    where 'action is null or action != ?', AnimeHistoryAction::Episode
  }

  def to_param
    "%d-%s" % [id, permalink]
  end

  def permalink
    title&.permalinked
  end

  def cache_key
    "#{super}-#{Digest::MD5.hexdigest body || ''}"
  end

  # базовый класс для комментариев
  def base_class
    Entry
  end

  # прочтен ли топик?
  def viewed?
    generated? ? true : super
  end

  # колбек, срабатываемый при добавлении коммента
  def comment_added comment
    self.updated_at = Time.zone.now
    # because automatically generated topics have no created_at
    self.created_at ||= self.updated_at if self.comments_count == 1 && !generated_news?
    save
  end

  # колбек, срабатываемый при удалении коммента
  def comment_deleted comment
    self.class.wo_timestamp do
      update(
        updated_at: self.comments.count > 0 ? self.comments.first.created_at : self.created_at,
        comments_count: self.comments.count
      )
    end
  end

  # оффтопик ли это? для совместимости с интерфейсом отображения комментариев
  def offtopic?
    false
  end

  # forum topic created by user
  def topic?
    self.class == Topic
  end

  # сгенерированный ли топик
  def generated?
    generated
  end

  # новостной ли это топиик?
  def news?
    /News/ === self.class.name
  end

  # топик ли это сгенерированной новости?
  def generated_news?
    news? && generated?
  end

  def review?
    is_a? Topics::EntryTopics::ReviewTopic
  end

  def cosplay?
    is_a? Topics::EntryTopics::CosplayGalleryTopic
  end

  def contest?
    is_a? Topics::EntryTopics::ContestTopic
  end

  # оригинальный текст без сгенерированных автоматом тегов
  def original_body
    if generated?
      body
    else
      (body || '').sub(NEWS_WALL, '')
    end
  end

  # сгенерированные автоматом теги
  def appended_body
    if generated?
      ''
    else
      (body || '')[NEWS_WALL] || ''
    end
  end

private

  # проверка, что linked при его наличии нужного типа
  def validates_linked
    return unless self[:linked_type].present? &&
      self[:linked_type] !~ /^(Anime|Manga|Character|Person|Club|Review|Contest|CosplayGallery)$/
    errors[:linked_type] = 'Forbidden Linked Type'
    return false
  end
end

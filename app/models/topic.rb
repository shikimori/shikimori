# frozen_string_literal: true

class Topic < ActiveRecord::Base
  include Commentable
  include Moderatable
  include Antispam
  include Viewable

  NEWS_WALL = /[\r\n]*\[wall[\s\S]+\[\/wall\]\Z/

  FORUM_IDS = {
    'Anime' => 1,
    'Manga' => 1,
    'Character' => 1,
    'Person' => 1,
    'Club' => Forum::CLUBS_ID,
    'Review' => 12,
    'Contest' => Forum::CONTESTS_ID,
    'CosplayGallery' => Forum::COSPLAY_ID
  }

  belongs_to :anime_history
  belongs_to :forum
  belongs_to :linked, polymorphic: true
  belongs_to :user

  validates :forum, :user, :locale, presence: true
  validates :title, :body, presence: true, unless: :generated?

  enumerize :locale, in: %i(ru en), predicates: { prefix: true }

  has_many :messages,
    -> { where "linked_type = '#{self.class.name}' or linked_type = '#{Entry.name}'" },
    foreign_key: :linked_id,
    dependent: :delete_all

  has_many :topic_ignores,
    foreign_key: :topic_id,
    dependent: :destroy

  # топики без топиков о выходе эпизодов
  scope :wo_episodes, -> {
    where 'action IS NULL OR action != ?', AnimeHistoryAction::Episode
  }

  before_save :validates_linked

  def title
    return self[:title]&.html_safe if user&.bot?
    self[:title]
  end

  def viewed?
    generated? ? true : super
  end

  def to_param
    "%d-%s" % [id, permalink]
  end

  def permalink
    title&.permalinked
  end

  def cache_key
    "#{super}-#{Digest::MD5.hexdigest body || ''}"
  end

  # callback when comment is added
  def comment_added comment
    self.updated_at = Time.zone.now
    # because automatically generated topics have no created_at
    self.created_at ||= self.updated_at if self.comments_count == 1 && !generated_news?
    save
  end

  # callback when comment is deleted
  def comment_deleted comment
    self.class.wo_timestamp do
      update(
        updated_at: self.comments.count > 0 ? self.comments.first.created_at : self.created_at,
        comments_count: self.comments.count
      )
    end
  end

  # for compatibily with comment API
  def offtopic?
    false
  end

  # forum topic created by user
  def forum_topic?
    self.class == Topic
  end

  def generated?
    generated
  end

  def news_topic?
    false
  end

  def generated_news?
    news_topic? && generated?
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

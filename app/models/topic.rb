# frozen_string_literal: true

class Topic < ApplicationRecord
  include Antispam
  include Commentable
  include Moderatable
  include Viewable
  include ElasticsearchConcern

  NEWS_WALL = /[\r\n]*\[wall[\s\S]+\[\/wall\]\Z/

  FORUM_IDS = {
    'Anime' => 1,
    'Manga' => 1,
    'Ranobe' => 1,
    'Character' => 1,
    'Person' => 1,
    'Club' => Forum::CLUBS_ID,
    'ClubPage' => Forum::CLUBS_ID,
    'Review' => 12,
    'Contest' => Forum::CONTESTS_ID,
    'CosplayGallery' => Forum::COSPLAY_ID,
    'Collection' => Forum::COLLECTION_ID
  }

  TOPIC_IDS = {
    Forum::OFFTOPIC_ID => {
      offtopic: { ru: 82_468, en: 210_000 },
      site_rules: { ru: 79_042, en: 220_000 },
      # faq: { ru: 85_018, en: nil },
      description_of_genres: { ru: 103_553, en: nil },
      ideas_and_suggestions: { ru: 10_586, en: 230_000 },
      site_problems: { ru: 102, en: 240_000 }
    },
    Forum::SITE_ID => {
      anime_industry: { ru: 81_906, en: 250_000 }
    }
  }

  belongs_to :forum
  belongs_to :linked, polymorphic: true
  belongs_to :user

  validates :forum, :user, :locale, presence: true
  validates :title, :body, presence: true, unless: :generated?

  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }

  has_many :messages,
    -> { where "linked_type = '#{Topic.name}'" },
    foreign_key: :linked_id,
    dependent: :delete_all

  has_many :topic_ignores,
    foreign_key: :topic_id,
    dependent: :destroy

  # топики без топиков о выходе эпизодов
  scope :wo_episodes, -> {
    where 'action IS NULL OR action != ?', AnimeHistoryAction::Episode
  }

  before_save :validate_linked

  def title
    return self[:title]&.html_safe if user&.bot?
    self[:title]
  end

  def viewed?
    return true if generated?
    # invokes Viewable#viewed?
    super
  end

  def to_param
    "#{id}-#{permalink}"
  end

  def permalink
    title&.permalinked
  end

  # callback when comment is added
  def comment_added comment
    self.updated_at = Time.zone.now

    if self.comments_count == 1 &&
        !Topic::TypePolicy.new(self).generated_news_topic?
      # automatically generated topics have no created_at
      self.created_at ||= self.updated_at
    end

    save
  end

  # callback when comment is deleted
  def comment_deleted comment
    updated_at = if self.comments.count > 0
      comments.first.created_at
    else
      self.created_at
    end

    self.class.wo_timestamp do
      update(
        updated_at: updated_at,
        comments_count: comments.count
      )
    end
  end

  # for compatibily with comments API
  def offtopic?
    false
  end

  # оригинальный текст без сгенерированных автоматом тегов
  def original_body
    return body if generated?
    (body || '').sub(NEWS_WALL, '')
  end

  # сгенерированные автоматом теги
  def appended_body
    return '' if generated?
    (body || '')[NEWS_WALL] || ''
  end

private

  def validate_linked
    return if linked_type.blank?

    match = linked_type =~ /
      ^(
        Anime|
        Manga|
        Character|
        Person|
        Club|
        ClubPage|
        Review|
        Contest|
        CosplayGallery|
        Collection
      )$
    /x
    return if match.present?

    errors.add :linked_type, 'Forbidden Linked Type'
    throw :abort
  end
end

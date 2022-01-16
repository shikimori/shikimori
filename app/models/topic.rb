# frozen_string_literal: true

class Topic < ApplicationRecord # rubocop:disable ClassLength
  include AntispamConcern
  include Commentable
  include DecomposableBodyConcern
  include Moderatable
  include Viewable

  antispam(
    interval: 1.minute,
    disable_if: -> { user.admin? && Rails.env.development? },
    user_id_key: :user_id
  )

  update_index('topics#topic') do
    self if saved_change_to_title? || saved_change_to_forum_id?
  end

  FORUM_IDS = {
    'Anime' => 1,
    'Manga' => 1,
    'Ranobe' => 1,
    'Character' => 1,
    'Person' => 1,
    'Club' => Forum::CLUBS_ID,
    'ClubPage' => Forum::CLUBS_ID,
    'Critique' => Forum::CRITIQUES_ID,
    'Review' => Forum::REVIEWS_ID,
    'Contest' => Forum::CONTESTS_ID,
    'CosplayGallery' => Forum::COSPLAY_ID,
    'Collection' => Forum::COLLECTIONS_ID,
    'Article' => Forum::ARTICLES_ID
  }

  TOPIC_IDS = {
    offtopic: { ru: 82_468, en: 210_000 },
    site_rules: { ru: 79_042, en: 220_000 },
    description_of_genres: { ru: 103_553, en: nil },
    ideas_and_suggestions: { ru: 10_586, en: 230_000 },
    site_problems: { ru: 102, en: 240_000 },
    anime_industry: { ru: 81_906, en: 250_000 },
    contests_proposals: { ru: 212_657 },
    socials: { ru: 270_099 }
  }

  LINKED_TYPES = %w[
    Anime
    Manga
    Ranobe
    Character
    Person
    Club
    ClubPage
    Critique
    Review
    Contest
    CosplayGallery
    Collection
    Article
  ]

  belongs_to :forum
  belongs_to :linked, polymorphic: true, optional: true
  belongs_to :user

  validates :forum, :user, :locale, presence: true
  validates :title, :body, presence: true, unless: :generated?

  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }

  has_many :messages,
    -> { where linked_type: Topic.name },
    inverse_of: :linked,
    foreign_key: :linked_id,
    dependent: :delete_all

  has_many :topic_ignores,
    dependent: :destroy

  has_many :abuse_requests, -> { order :id },
    dependent: :destroy,
    inverse_of: :topic
  has_many :bans, -> { order :id },
    inverse_of: :topic

  # топики без топиков о выходе эпизодов
  scope :wo_episodes, -> {
    where 'action IS NULL OR action != ?', AnimeHistoryAction::Episode
  }
  scope :user_topics, -> {
    where type: [nil, Topic.name, Topics::NewsTopic.name]
  }

  before_save :validate_linked
  before_save :check_spam_abuse, if: :will_save_change_to_body?
  before_save :fill_created_at, if: :will_save_change_to_comments_count?

  def title
    return self[:title]&.html_safe if User::BOT_IDS.include? user_id

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

  # for compatibily with comments API
  def offtopic?
    false
  end

  def faye_channels
    %W[/topic-#{id}]
  end

private

  def validate_linked
    return if linked_type.blank? || LINKED_TYPES.include?(linked_type)

    errors.add :linked_type, 'Forbidden Linked Type'
    throw :abort
  end

  def fill_created_at
    return if created_at || comments_count.zero?

    self.created_at ||= Time.zone.now
  end

  def check_spam_abuse
    unless Users::CheckHacked.call(model: self, text: body, user: user)
      throw :abort
    end
  end
end

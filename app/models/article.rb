class Article < ApplicationRecord
  include AntispamConcern
  include ModeratableConcern
  include TopicsConcern

  antispam(
    per_day: 5,
    user_id_key: :user_id
  )
  update_index('articles#article') { self if saved_change_to_name? }

  belongs_to :user
  validates :name, :user, :body, presence: true
  validates :locale, presence: true

  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }
  enumerize :state, in: Types::Collection::State.values, predicates: true

  scope :unpublished, -> { where state: :unpublished }
  scope :published, -> { where state: :published }
  scope :available, -> { published.where.not(moderation_state: :rejected) }

  def to_param
    "#{id}-#{name.permalinked}"
  end

  # compatibility with DbEntry
  def topic_user
    user
  end

  def description_ru
    body
  end

  def description_en
    body
  end
end

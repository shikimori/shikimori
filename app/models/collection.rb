class Collection < ApplicationRecord
  include AntispamConcern
  include TopicsConcern
  include ModeratableConcern

  antispam(
    interval: 15.minutes,
    user_id_key: :user_id
  )

  acts_as_votable cacheable_strategy: :update_columns
  update_index('collections#collection') { self if saved_change_to_name? }

  belongs_to :user
  has_many :links, -> { order :id },
    class_name: CollectionLink.name,
    dependent: :destroy

  validates :name, :user, :kind, presence: true
  validates :locale, presence: true

  enumerize :kind, in: Types::Collection::Kind.values, predicates: true
  enumerize :state, in: Types::Collection::State.values, predicates: true
  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }

  scope :unpublished, -> { where state: :unpublished }
  scope :published, -> { where state: :published }
  scope :available, -> { published.where.not(moderation_state: :rejected) }

  def to_param
    "#{id}-#{name.permalinked}"
  end

  def topic_user
    user
  end

  # для совместимости с DbEntry
  def description_ru
    text
  end

  # для совместимости с DbEntry
  def description_en
    text
  end
end

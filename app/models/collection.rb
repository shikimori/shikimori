class Collection < ApplicationRecord
  include ClubsConcern
  include AntispamConcern
  include TopicsConcern
  include ModeratableConcern

  antispam(
    per_day: 5,
    user_id_key: :user_id
  )

  acts_as_votable cacheable_strategy: :update_columns
  update_index('collections#collection') { self if saved_change_to_name? }

  belongs_to :user
  has_many :links, -> { order :id },
    inverse_of: :collection,
    class_name: 'CollectionLink',
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

  def db_type
    if ranobe?
      Types::Collection::Kind[:manga].to_s.capitalize
    else
      kind.capitalize
    end
  end

  # compatibility with DbEntry
  def topic_user
    user
  end

  def description_ru
    text
  end

  def description_en
    text
  end
end

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

  belongs_to :user, touch: :activity_at
  has_many :links, -> { order :id },
    inverse_of: :collection,
    class_name: 'CollectionLink',
    dependent: :destroy
  has_many :collection_roles, dependent: :destroy
  has_many :coauthors, through: :collection_roles, source: :user

  validates :name, :user, :kind, presence: true
  validates :locale, presence: true

  enumerize :kind, in: Types::Collection::Kind.values, predicates: true
  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }
  # enumerize :state, in: Types::Collection::State.values, predicates: true

  scope :unpublished, -> { where state: :unpublished }
  scope :published, -> { where state: :published }

  scope :available, -> { visible.published }
  scope :publicly_available, -> {
    available.or(where(state: Types::Collection::State[:opened]))
  }

  state_machine :state, initial: :unpublished do
    state Types::Collection::State[:published]
    state Types::Collection::State[:private]
    state Types::Collection::State[:opened]
    state Types::Collection::State[:unpublished]

    event :to_published do
      transition %i[unpublished private opened] =>
        Types::Collection::State[:published]
    end
    event :to_private do
      transition %i[unpublished published opened] =>
        Types::Collection::State[:private]
    end
    event :to_opened do
      transition %i[unpublished published private] =>
        Types::Collection::State[:opened]
    end

    # before_transition %i[unpublished private opened] => :published do |collection, _transition|
    #   collection.published_at ||= Time.zone.now
    # end
  end

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

  def coauthor? user
    collection_role(user).present?
  end

  def collection_role user
    collection_roles.find { |v| v.user_id == user.id }
  end
end

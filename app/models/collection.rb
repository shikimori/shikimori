class Collection < ApplicationRecord
  include TopicsConcern

  belongs_to :user
  has_many :links,
    -> { order :id },
    class_name: CollectionLink.name,
    dependent: :destroy

  validates :name, :user, :kind, presence: true
  validates :locale, presence: true

  enumerize :kind, in: Types::Collection::Kind.values, predicates: true
  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }

  state_machine :state, initial: :pending do
    state :pending, :published

    event(:publish) { transition pending: :published }
    event(:unpublish) { transition published: :pending }
  end

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

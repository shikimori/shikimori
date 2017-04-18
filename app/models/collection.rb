class Collection < ApplicationRecord
  include TopicsConcern

  belongs_to :user

  validates :name, :user, :kind, presence: true
  validates :locale, presence: true

  enumerize :kind, in: Types::Collection::Kind.values, predicates: true
  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }

  def to_param
    "#{id}-#{name.permalinked}"
  end

  def topic_user
    user
  end
end

class Collection < ApplicationRecord
  include TopicsConcern

  belongs_to :user

  validates :name, :user, presence: true
  validates :locale, presence: true

  enumerize :locale, in: %i[ru en], predicates: { prefix: true }

  def to_param
    "#{id}-#{name.permalinked}"
  end

  def topic_user
    user
  end
end

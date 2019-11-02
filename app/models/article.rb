class Article < ApplicationRecord
  include AntispamConcern
  include TopicsConcern
  include ModeratableConcern

  antispam(
    per_day: 5,
    user_id_key: :user_id
  )
  update_index('articles#article') { self if saved_change_to_name? }

  belongs_to :user
  validates :name, :user, :kind, presence: true
  validates :locale, presence: true

  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }

  def to_param
    "#{id}-#{name.permalinked}"
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

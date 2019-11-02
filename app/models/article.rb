class Article < ApplicationRecord
  include AntispamConcern
  include TopicsConcern
  include ModeratableConcern

  belongs_to :user
  validates :name, :user, :kind, presence: true
  validates :locale, presence: true

  enumerize :locale, in: Types::Locale.values, predicates: { prefix: true }
end

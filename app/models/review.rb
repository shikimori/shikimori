# frozen_string_literal: true

class Review < ApplicationRecord
  include Antispam
  include Moderatable
  include TopicsConcern
  include ModeratableConcern

  acts_as_voteable

  MINIMUM_LENGTH = 3000

  belongs_to :target, polymorphic: true, touch: true
  belongs_to :user

  validates :user, :target, presence: true
  validates :text,
    length: {
      minimum: MINIMUM_LENGTH,
      too_short: "too short (#{MINIMUM_LENGTH} symbols minimum)"
    },
    if: -> { changes['text'] }
  validates :locale, presence: true

  enumerize :locale, in: %i(ru en), predicates: { prefix: true }

  def topic_user
    user
  end

  # хз что это за хрень и почему ReviewComment.first.linked.target
  # возвращает сам обзор. я так и не понял
  def entry
    @entry ||= Object.const_get(target_type).find(target_id)
  end

  def body
    text
  end
end

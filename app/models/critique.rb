# frozen_string_literal: true

class Critique < ApplicationRecord
  include AntispamConcern
  include Moderatable
  include TopicsConcern
  include ModeratableConcern

  antispam(
    per_day: 3,
    user_id_key: :user_id
  )

  acts_as_votable cacheable_strategy: :update_columns

  MINIMUM_LENGTH = 3000

  belongs_to :user,
    touch: Rails.env.test? ? false : :activity_at
  belongs_to :target, polymorphic: true, touch: true

  validates :user, :target, presence: true
  validates :text,
    length: {
      minimum: MINIMUM_LENGTH,
      too_short: "too short (#{MINIMUM_LENGTH} symbols minimum)"
    },
    if: -> { changes['text'] }
  validates :locale, presence: true

  enumerize :locale, in: %i[ru en], predicates: { prefix: true }

  scope :available, -> { visible }

  def topic_user
    user
  end

  # хз что это за хрень и почему CritiqueComment.first.linked.target
  # возвращает сам обзор. я так и не понял
  def entry
    @entry ||= target_type.constantize.find(target_id)
  end

  def body
    text
  end
end

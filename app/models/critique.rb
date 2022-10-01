# frozen_string_literal: true

class Critique < ApplicationRecord
  include AntispamConcern
  include Behaviour::Moderatable
  include TopicsConcern
  include ModeratableConcern

  antispam(
    per_day: 3,
    user_id_key: :user_id
  )

  acts_as_votable cacheable_strategy: :update_columns

  MIN_BODY_SIZE = 3000

  belongs_to :user,
    touch: Rails.env.test? ? false : :activity_at
  belongs_to :target, polymorphic: true, touch: true

  validates :text,
    length: {
      minimum: MIN_BODY_SIZE,
      too_short: "too short (#{MIN_BODY_SIZE} symbols minimum)"
    },
    if: -> { changes['text'] }

  alias topic_user user
  delegate :censored?, to: :target, allow_nil: true

  scope :available, -> { visible }

  def body
    text
  end

  def db_entry_type
    return unless target_id

    if target_type == Anime.name
      target_type
    else
      target.class.name
    end
  end
end

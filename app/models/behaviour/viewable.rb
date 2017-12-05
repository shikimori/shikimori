# frozen_string_literal: true

# refactor to models/concerns
# either Topic or Comment so far
module Viewable
  extend ActiveSupport::Concern

  MAX_NOT_VIEWED_INTERVAL = 1.week

  included do |klass|
    klass.const_set(
      'VIEWED_JOINS_SELECT',
      'COALESCE(v.viewed_id, 0) > 0 AS viewed'
    )

    # base_class returns class descending directly from ApplicationRecord
    # (that is either Topic or Comment model)
    viewing_klass = "#{base_class.name}Viewing".constantize

    # f**king gem breaks assigning associations in FactoryBot
    if Rails.env.test?
      has_many :viewings,
        class_name: viewing_klass.name,
        foreign_key: :viewed_id
    else
      has_many :viewings,
        class_name: viewing_klass.name,
        foreign_key: :viewed_id,
        dependent: :delete_all
    end

    # create viewing for the author right after create
    after_create -> { viewing_klass.create! user_id: user_id, viewed_id: id }

    scope :with_viewed, -> (user) {
      return select("#{table_name}.*") unless user

      select("#{table_name}.*, #{klass::VIEWED_JOINS_SELECT}")
      .joins(
        "LEFT JOIN #{viewing_klass.table_name} v
          ON v.viewed_id = #{table_name}.id AND v.user_id = '#{user.id}'"
      )
    }
  end

  def viewed?
    return true if self[:viewed].nil?
    return true if created_at < MAX_NOT_VIEWED_INTERVAL.ago

    self[:viewed]
  end
end

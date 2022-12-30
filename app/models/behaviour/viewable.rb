# frozen_string_literal: true

module Behaviour::Viewable
  extend ActiveSupport::Concern

  MAX_NOT_VIEWED_INTERVAL = 1.week

  included do |klass|
    klass.const_set(
      'VIEWED_JOINS_SELECT',
      'COALESCE(v.viewed_id, 0) > 0 AS viewed'
    )

    # base_class returns class descending directly from ApplicationRecord
    # (that is either Topic or Comment model)
    klass.const_set(
      'VIEWING_KLASS',
      "#{base_class.name}Viewing".constantize
    )

    # f**king gem breaks assigning associations in FactoryBot
    if Rails.env.test?
      has_many :viewings, # rubocop:disable HasManyOrHasOneDependent
        class_name: "#{base_class.name}Viewing",
        foreign_key: :viewed_id,
        inverse_of: :viewed
    else
      has_many :viewings,
        class_name: "#{base_class.name}Viewing",
        foreign_key: :viewed_id,
        dependent: :delete_all,
        inverse_of: :viewed
    end

    # create viewing for the author right after create
    after_create :create_viewing

    scope :with_viewed, ->(user) {
      return select("#{table_name}.*") unless user

      select("#{table_name}.*, #{klass::VIEWED_JOINS_SELECT}")
        .joins(
          Arel.sql(
            <<-SQL.squish
              left join #{klass::VIEWING_KLASS.table_name} v
                on v.viewed_id = #{table_name}.id and v.user_id = '#{user.id}'
            SQL
          )
        )
    }
  end

  def viewed?
    return true if self[:viewed].nil?
    return true if created_at < MAX_NOT_VIEWED_INTERVAL.ago

    self[:viewed]
  end

private

  def create_viewing
    self.class::VIEWING_KLASS.create! user_id: user_id, viewed_id: id
  end
end

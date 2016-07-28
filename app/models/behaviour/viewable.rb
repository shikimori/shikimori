# either Topic or Comment so far
module Viewable
  extend ActiveSupport::Concern

  MAX_NOT_VIEWED_INTERVAL = 1.week

  included do |klass|
    viewing_klass = "#{base_class.name}Viewing".constantize

    # f**king gem breaks assigning associations in FactoryGirl
    # and IDK how to fix it quickly
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

    klass.const_set(
      'VIEWED_JOINS_SELECT',
      "coalesce(jv.#{name.downcase}_id, 0) > 0 as viewed"
    )

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
    return true unless self[:viewed]
    return true if created_at < MAX_NOT_VIEWED_INTERVAL.ago

    self[:viewed]
  end
end

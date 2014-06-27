module Viewable
  extend ActiveSupport::Concern

  included do
    klass_name = (self.respond_to?(:base_class) ? base_class.name : name)
    view_klass = Object.const_get(klass_name + 'View')

    # чёртов гем ломает присвоение ассоциаций в FactoryGirl, и я не знаю, как это быстро починить другим способом
    if Rails.env.test?
      has_many :views, class_name: view_klass.name
    else
      has_many :views, class_name: view_klass.name, dependent: :delete_all
    end

    # для автора сразу же создаётся view
    after_create lambda {
      view_klass.create! user_id: self.user_id, klass_name.downcase => self
    }

    scope :with_viewed, lambda { |user|
      if user
        joins("left join #{view_klass.table_name} jv on jv.#{name.downcase}_id=#{table_name}.id and jv.user_id='#{user.id}'")
          .select("#{table_name}.*, coalesce(jv.#{name.downcase}_id, 0) as viewed")
      else
        select("#{table_name}.*")
      end
    }
  end

  def viewed?
    self[:viewed].nil? || (created_at + 1.month < Date.today) ? true : self[:viewed].to_i == 1
  end
end

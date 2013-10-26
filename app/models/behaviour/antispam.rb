module Antispam
  extend ActiveSupport::Concern

  included do
    before_create :check_antispam
    @antispam = true
  end

  module ClassMethods
    def antispam=(val)
      @antispam = val
    end

    def wo_antispam(&block)
      @antispam = false
      val = yield
      @antispam = true
      val
    end

    def with_antispam?
      @antispam
    end
  end

  def with_antispam?
    self.class.with_antispam?
  end

  def check_antispam
    return if id # если id есть, значит это редактирование
    return unless with_antispam?

    prior = self.class.where(user_id: user_id)
                      .order('id desc')
                      .first
    return unless prior
    return if BotsService.posters.include?(self.user_id)

    if prior && DateTime.now.to_i - prior.created_at.to_i < 15
      interval = 15 - (DateTime.now.to_i - prior.created_at.to_i)
      errors['created_at'] = 'Защита от спама. Попробуйте снова через %d %s.' % [interval, Russian.p(interval, 'секунду', 'секунды', 'секунд')]
      return false
    end
  end
end

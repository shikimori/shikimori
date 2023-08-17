class JsExports::Supervisor
  include Singleton

  USER_KEYS = %i[user_rates topics comments polls]
  GUEST_KEYS = %i[polls]

  def export user
    user_export user, self.class.user_keys(user)
  end

  def sweep user, html
    return html if html.blank?

    self.class.user_keys(user).each do |key|
      instance(key).sweep html
    end

    html
  end

  def self.user_keys user
    user ? USER_KEYS : GUEST_KEYS
  end

private

  def user_export user, keys
    ability = Ability.new user if user

    keys.index_with do |key|
      instance(key).export(user, ability)
    end
  end

  def instance key
    "JsExports::#{key.to_s.classify.pluralize}Export".constantize.instance
  end
end

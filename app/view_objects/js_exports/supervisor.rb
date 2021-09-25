class JsExports::Supervisor
  include Singleton

  KEYS = %i[user_rates topics reviews comments polls]

  def export user
    return unless user

    KEYS.each_with_object({}) do |key, memo|
      memo[key] = instance(key).export user
    end
  end

  def sweep html
    return html if html.blank?

    KEYS.each do |key|
      instance(key).sweep html
    end
    html
  end

private

  def instance key
    "JsExports::#{key.to_s.classify.pluralize}Export".constantize.instance
  end
end

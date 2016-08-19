class JsExports::Supervisor
  include Singleton

  KEYS = %i(user_rates topics)

  def export user
    return unless user

    KEYS.each_with_object({}) do |key, memo|
      memo[key] = send(key).export user
    end
  end

  def sweep html
    return html if html.blank?

    KEYS.each do |key|
      send(key).sweep html
    end
    html
  end

private

  def user_rates
    JsExports::UserRatesExport.instance
  end

  def topics
    JsExports::TopicsExport.instance
  end
end

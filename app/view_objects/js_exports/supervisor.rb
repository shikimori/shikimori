class JsExports::Supervisor
  include Singleton
  include Draper::ViewHelpers

  KEYS = %i(user_rates topics)

  def export
    KEYS.each_with_object({}) do |key, memo|
      memo[key] = send(key).export h.current_user
    end
  end

  def sweep html = nil, &block
    html ||= h.capture(&block)

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

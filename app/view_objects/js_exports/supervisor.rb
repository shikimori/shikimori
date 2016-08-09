class JsExports::Supervisor
  include Singleton
  include Draper::ViewHelpers

  KEYS = %i(tracked_user_rates)

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

  def tracked_user_rates
    JsExports::UserRates.instance
  end
end

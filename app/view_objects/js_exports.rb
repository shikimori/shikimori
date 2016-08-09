class JsExports
  include Singleton
  include Draper::ViewHelpers

  KEYS = %i(tracked_user_rates)

  def export
    KEYS.each_with_object({}) do |key, memo|
      memo[key] = send key
    end
  end

private

  def tracked_user_rates
    UserRates::Tracker.instance.export h.current_user
  end
end

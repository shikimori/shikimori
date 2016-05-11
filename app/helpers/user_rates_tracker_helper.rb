module UserRatesTrackerHelper
  def sweep_user_rates &block
    html = capture &block
    UserRates::Tracker.instance.sweep html
    html
  end
end

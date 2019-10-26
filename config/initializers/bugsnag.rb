if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'b30943491e48520cf420b69fd04dee1d'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

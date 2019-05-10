if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'dc3866c9671ff8cbee3810c940b1aae3'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

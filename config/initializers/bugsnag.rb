if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '7f74b888d4ac4fbb32025189a33c6c4e'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

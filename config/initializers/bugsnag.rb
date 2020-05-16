if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '412f34fae4a28b72074b65e0fe4ae988'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

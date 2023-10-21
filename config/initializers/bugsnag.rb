if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '2614484e67d2d2e377ec0f2a6f12afd2'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

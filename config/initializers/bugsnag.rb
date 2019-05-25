if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '48a2b992f3e867ecfde9271836408a0b'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

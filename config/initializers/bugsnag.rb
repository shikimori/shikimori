if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '7af675925e0d58890c3f7556cdab9c25'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

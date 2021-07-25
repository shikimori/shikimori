if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '84fbd656bcc5b27fbbae9d97c5f27dfd'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

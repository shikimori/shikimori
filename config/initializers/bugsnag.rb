if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'c7b85d3c8bf57654db2c2b8091ec0d2f'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

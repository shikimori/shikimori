if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '6c693576681daba5b75aea7f08da679b'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

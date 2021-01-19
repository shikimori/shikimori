if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '8ba616c448495b63e28f674a6b472f54'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

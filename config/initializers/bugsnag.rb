if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'ddc5a1c19acba6ee8c734febc5af5dbf'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

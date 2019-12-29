if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'c32e9b7f70482e678ffc1bf3dbdd6c06'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

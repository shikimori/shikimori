if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '5f2ff9d328d6ae407777a40b70629c3c'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

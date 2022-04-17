if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'bffb3a3c90edbd387defa1eb04196ff0'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

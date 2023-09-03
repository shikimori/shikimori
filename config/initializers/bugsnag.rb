if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '7481d1e53694eeabd7eddc852b689605'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '45d68c9a750a57afe47334157d9eede5'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

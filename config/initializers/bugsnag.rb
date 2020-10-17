if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '11f1f04220a24856e5ac616275859ee2'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

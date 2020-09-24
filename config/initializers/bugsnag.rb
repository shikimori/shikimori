if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '79359a2e89238df32af8593c1daeffdb'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

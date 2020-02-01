if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '7534cb88b83d63b9f88d5f97a32dbd57'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

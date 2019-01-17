if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '1fefb1e602ad951eb3bb2e098f94be9c'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '2a7660999663e080e4b5d7b581cecd19'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

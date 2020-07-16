if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'bc39a301a4b5c28f5288800edfdd82ec'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

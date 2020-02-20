if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'f1226a710ae2f39f80f567cc27a6b9b0'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

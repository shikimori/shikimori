if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'f6c2c05e3d8e2a1bd9962fd46a21a172'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

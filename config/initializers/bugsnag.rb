if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'cfdf6d2fdf6ac9d77633367588a0d42c'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

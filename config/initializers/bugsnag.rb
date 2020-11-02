if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '7c9657701360e28d43484c2939ad3f4c'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

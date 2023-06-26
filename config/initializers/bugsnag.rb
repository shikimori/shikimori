if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '2d8e01cf12c81a77be1c5a772442e44b'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

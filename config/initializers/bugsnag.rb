if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'be9c5c2c2abd36583c8d3c4ee1015e68'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'aa38f839009a3b8652f2b48b32baaa23'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '406b2ffcaa736d770c0b8cfabe2e2800'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

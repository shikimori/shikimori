if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '20e1d49c59f8fd494b265bd245d2d40b'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

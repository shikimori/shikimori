if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '320c26e9bf6a5d7e6e25d8ffc08dcee5'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

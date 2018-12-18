if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'b25569101cfa3ef5572895f72b70b0ed'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

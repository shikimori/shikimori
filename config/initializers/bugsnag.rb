if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'f916cca439d63640b542a6116b5e2aad'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

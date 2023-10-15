if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '1f050e588323b19d8fcb4fbaa9a7e17e'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '573276690f2242416c8ef178f895cc78'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

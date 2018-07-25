if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'fcfa5d72e998a5b825ecc942aaff9dc1'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

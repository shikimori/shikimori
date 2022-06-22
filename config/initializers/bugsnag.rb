if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '98582fcc8ba3b80be757901c4c1dc04d'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '45053841b2bd7d0f19822e1382481249'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

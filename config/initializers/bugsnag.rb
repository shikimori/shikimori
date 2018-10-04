if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'b6d7efbebcfdc1e54f602cea1ba8adc0'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

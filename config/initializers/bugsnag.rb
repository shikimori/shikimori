if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '8a771eb9be67bf01e7b7f17f390a902f'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

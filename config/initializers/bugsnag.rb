if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '80d8d434ca68a4b197b95faa47895f17'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

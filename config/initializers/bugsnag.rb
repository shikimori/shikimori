if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '8def9719699109559c9910f8f5a73787'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

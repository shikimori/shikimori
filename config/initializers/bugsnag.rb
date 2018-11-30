if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'e972051d62a756aab47111a9e740b8a5'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

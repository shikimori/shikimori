if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'bb4832a027d32a452cf4a43fb491f3dc'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '25b448c39764576885c0e1e53bda8a99'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

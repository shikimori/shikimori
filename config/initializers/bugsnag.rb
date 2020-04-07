if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'd7a552b587fa9a23cfb37fb630f3a0e0'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

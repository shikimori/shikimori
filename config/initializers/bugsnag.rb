if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '9f124d8db0dcbac29c7dce8d1892a4e1'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

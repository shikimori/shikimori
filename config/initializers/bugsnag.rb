if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '13facc6d8be8f234e594695f9a61b9a9'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

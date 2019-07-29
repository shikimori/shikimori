if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '2e7d1fd52a9590607b3471fa9fb4e9a5'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

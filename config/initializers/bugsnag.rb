if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '30578865a35a3c65bca96e9846ca1ab1'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

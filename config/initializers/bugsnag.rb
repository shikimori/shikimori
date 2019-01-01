if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '218151b7d0f046bb8e92efe4771afc80'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'ec4aeea0fee9975e94f32bd3032ea2a8'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

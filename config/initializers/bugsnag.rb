if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '237d98930b2390ffe65c32bdd656e7a8'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

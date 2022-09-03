if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '7a853ba1ea1614a3d2edb3771051f702'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

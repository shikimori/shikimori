if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '96ef56adb0a473dd289ef827315ac760'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

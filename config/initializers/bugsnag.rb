if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '205623c44ebac17fbb2c23fcdb01b806'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

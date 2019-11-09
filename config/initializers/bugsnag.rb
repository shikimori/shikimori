if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '32d4888f992c6a7f7dbfd783dae540c5'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

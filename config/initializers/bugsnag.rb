if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '91511aee24995957c05b0f51e187dd39'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

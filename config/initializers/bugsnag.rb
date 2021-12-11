if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'fbe86381e056bf3aa87e6c481aa68aa2'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

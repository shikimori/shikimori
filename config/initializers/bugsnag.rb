if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '3b7fdc59d612949964769bd67a2898d8'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

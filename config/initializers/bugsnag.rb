if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'dd9f8e68e09e6e587152d1cc2dd8337c'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

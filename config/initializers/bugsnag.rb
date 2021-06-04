if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'f3b2af842e851c07e7d97d7a4c9ec7a1'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

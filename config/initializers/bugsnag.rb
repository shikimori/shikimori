if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'cbb138418d6899beab45e107d1f61964'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

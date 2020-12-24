if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '094b6b0eec37f602739654bbb10fe716'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

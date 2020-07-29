if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'd3ea8fcfdd5633d7853721747ce13d55'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

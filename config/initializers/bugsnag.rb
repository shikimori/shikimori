if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '75cbfe4cf342c5fc8e7e9746b09d476d'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

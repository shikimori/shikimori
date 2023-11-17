if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'b2baf38009494b2a6acd61a8c940d9ea'

    Shikimori::IGNORED_EXCEPTIONS.each do |klass|
      config.ignore_classes << klass
    end
  end
end

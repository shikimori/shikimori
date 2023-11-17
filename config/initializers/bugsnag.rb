if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'b2baf38009494b2a6acd61a8c940d9ea'
    config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }
  end
end

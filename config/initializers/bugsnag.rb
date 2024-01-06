if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'ffad25c27fa0e8e7c5d5a9a3ba925f5f'
    config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }
  end
end

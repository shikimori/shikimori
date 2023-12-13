if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'bd16dd05d285d815afb841c7dd13338b'
    config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }
  end
end

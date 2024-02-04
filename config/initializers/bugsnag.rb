if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'b965f3d1528d84e1b66cb54d68031389'
    config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }
  end
end

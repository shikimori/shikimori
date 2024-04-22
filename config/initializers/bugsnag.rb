if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '0c9ff54ce7f7b59d174cf722ae5c5d61'

    # config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }
    #
    # Shikimori::IGNORED_EXCEPTIONS.each do |class_name|
    #   config.discard_classes << class_name
    # end
  end
end

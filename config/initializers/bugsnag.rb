if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '021939c1780de638daee18bb65cb36cc'

    # config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }
    #
    # Shikimori::IGNORED_EXCEPTIONS.each do |class_name|
    #   config.discard_classes << class_name
    # end
  end
end

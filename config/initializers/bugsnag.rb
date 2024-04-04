if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '04fedd94e8bfac48900e5cb3ce44a013'

    config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }

    Shikimori::IGNORED_EXCEPTIONS.each do |class_name|
      config.discard_classes << class_name
    end
  end
end

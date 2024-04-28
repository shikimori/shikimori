if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '9e44228b59c1b3c3a6fdabb3466066da'

    config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }
    
    Shikimori::IGNORED_EXCEPTIONS.each do |class_name|
      config.discard_classes << class_name
    end
  end
end

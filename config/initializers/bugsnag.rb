BUGSNAG_API_KEY = '9e59a21fe788f5353d25d4a3433f8694'

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = BUGSNAG_API_KEY

    config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }

    Shikimori::IGNORED_EXCEPTIONS.each do |class_name|
      config.discard_classes << class_name
    end
  end
end

BUGSNAG_API_KEY = '9f654454da4f66c13221530d3ad81bc4'

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = BUGSNAG_API_KEY

    config.discard_classes << lambda { |ex| ex.class.name.in? Shikimori::IGNORED_EXCEPTIONS }

    Shikimori::IGNORED_EXCEPTIONS.each do |class_name|
      config.discard_classes << class_name
    end
  end
end

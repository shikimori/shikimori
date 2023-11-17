if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '13facc6d8be8f234e594695f9a61b9a9'

    Shikimori::IGNORED_EXCEPTIONS.each do |klass|
      config.ignore_classes << klass
    end
  end
end

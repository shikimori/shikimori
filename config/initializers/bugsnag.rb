if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '8805bf820d9c87662f1339568ad75767'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

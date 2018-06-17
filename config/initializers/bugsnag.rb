if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'd821ab4e51674f2e2eb46cdeef1543cc'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '8aae03017d14ad300fecbbaa978013a1'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'b4aa3e98f9ece48f86d571c4b1468d72'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

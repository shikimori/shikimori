if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'd38ec078839a8543ab3acd49e13dfe9b'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

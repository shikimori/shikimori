if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '8411c1288794dcdd5b0747161ef7d0e2'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

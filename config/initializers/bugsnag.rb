if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'b0d762b90f7c94a016164e513be5fa1c'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << klass
      end
  end
end

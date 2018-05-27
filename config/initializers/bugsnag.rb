if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = 'eecc8f1fe89fa10263c304de595d26ac'

    Shikimori::IGNORED_EXCEPTIONS
      .map { |v| v.constantize rescue NameError }
      .reject { |v| v == NameError }
      .each do |klass|
        config.ignore_classes << ActiveRecord::StatementInvalid
      end
  end
end

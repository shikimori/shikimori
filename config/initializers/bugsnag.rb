if defined? Bugsnag
  Bugsnag.configure do |config|
    config.api_key = '1aaa413a99f18af62d39ab5a62de4531'

    # Shikimori::IGNORED_EXCEPTIONS
    #   .map { |v| v.constantize rescue NameError }
    #   .reject { |v| v == NameError }
    #   .each do |klass|
    #     config.ignore_classes << klass
    #   end
  end
end

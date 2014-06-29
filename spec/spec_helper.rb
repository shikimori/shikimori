ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'spork'
require 'shoulda/matchers'
require 'paperclip/matchers'
require 'sidekiq/testing'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # This code will be run each time you run your specs.
  require 'factory_girl_rails'
  Spork.trap_class_method FactoryGirl, :find_definitions

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  RSpec.configure do |config|
    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.mock_with :rspec

    unless ENV['RSPEC_IGNORE_FOCUSED']
      config.filter_run focus: true
      config.run_all_when_everything_filtered = true
    end
    config.filter_run_excluding troublesome: true
    config.treat_symbols_as_metadata_keys_with_true_values = true

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.render_views
    config.order = 'random'

    config.before :suite do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with :truncation
      #DatabaseRewinder.clean_all
    end

    #HTTPI.log = false

    config.include FactoryGirl::Syntax::Methods
    config.include Devise::TestHelpers, type: :controller
    config.include Paperclip::Shoulda::Matchers, type: :model
  end

  Sidekiq::Testing.fake!

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/vcr_cassettes'
    c.hook_into :webmock
    c.allow_http_connections_when_no_cassette = true
    c.default_cassette_options = { match_requests_on: [:method, :uri, :query, :body], record: :new_episodes }
    c.configure_rspec_metadata!
  end

  module ActionController
    class TestResponse
      #def unauthorized?
        #@status == 401
      #end

      def unprocessible_entiy?
        @status == 422
      end
    end
  end
end

Spork.each_run do
  FactoryGirl.reload
  ActiveSupport::Dependencies.clear
  Rails.application.reload_routes!
end

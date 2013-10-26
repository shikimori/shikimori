ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'spork'
#require 'shoulda'
require 'paperclip/matchers'
require 'webmock/rspec'
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
      DatabaseRewinder.clean_all
    end

    VCR.configure do |c|
      c.cassette_library_dir = 'spec/vcr_cassettes'
      c.hook_into :webmock
      c.allow_http_connections_when_no_cassette = true
      c.default_cassette_options = { match_requests_on: [:method, :uri, :query, :body], record: :new_episodes }
    end

    #HTTPI.log = false

    config.include FactoryGirl::Syntax::Methods
    config.include Devise::TestHelpers, type: :controller
    config.include Paperclip::Shoulda::Matchers, type: :model

    module ActionController
      class TestResponse
        def unauthorized?
          @status == 401
        end

        def unprocessible_entiy?
          @status == 422
        end
      end
    end

  end

  #module Sidekiq::Worker::ClassMethods
    #def schedule(*args)
    #end
  #end

  #module Sidekiq::Worker::ClassMethods
    #def perform_async(*args)
    #end
  #end
end

Spork.each_run do
  ActiveRecord::Migration.check_pending! if Rails.version.to_i >= 4
  FactoryGirl.reload
  ActiveSupport::Dependencies.clear if RSpec.configuration.drb?
  Rails.application.reload_routes!
end
#require 'spork'

# This file is copied to spec/ when you run 'rails generate rspec:install'
#ENV["RAILS_ENV"] ||= 'test'
#require File.expand_path("../../config/environment", __FILE__)
#require 'rspec/rails'
#require 'capybara/rspec'
#require 'devise/test_helpers'
#require 'shoulda'
#require 'paperclip/matchers'
#require 'webmock/rspec'

#Spork.prefork do
  #ENV["RAILS_ENV"] ||= 'test'
  #require File.expand_path("../../config/environment", __FILE__)

  #require 'factory_girl_rails'
  #Spork.trap_class_method(FactoryGirl, :find_definitions)

  #require 'rspec/rails'
  ## Requires supporting ruby files with custom matchers and macros, etc,
  ## in spec/support/ and its subdirectories.
  #Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}


  #module AuthHelpers
    #def sign_in(user)
      #post_via_redirect new_user_session_path, 'user[nickname]' => user.nickname, 'user[password]' => FactoryGirl.attributes_for(:user)[:password]
    #end
  #end

  #module ActionController
    #class TestResponse
      #def unauthorized?
        #@status == 401
      #end

      #def unprocessible_entiy?
        #@status == 422
      #end
    #end
  #end

  #VCR.configure do |c|
    #c.cassette_library_dir = 'spec/vcr_cassettes'
    #c.hook_into :webmock # or :fakeweb
    #c.default_cassette_options = { record: :new_episodes, erb: true }
    #c.allow_http_connections_when_no_cassette = true
  #end

  #RSpec.configure do |config|
    #config.mock_with :rspec

    ## Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    ##config.fixture_path = "#{::Rails.root}/spec/fixtures"

    ## If you're not using ActiveRecord, or you'd prefer not to run each of your
    ## examples within a transaction, remove the following line or assign false
    ## instead of true.
    #config.use_transactional_fixtures = true

    #config.render_views

    #config.treat_symbols_as_metadata_keys_with_true_values = true

    #config.filter_run focus: true
    #config.run_all_when_everything_filtered = true

    #config.include FactoryGirl::Syntax::Methods
    #config.include Paperclip::Shoulda::Matchers, type: :model
    #config.include Devise::TestHelpers, type: :controller
    ##config.include AuthHelpers, type: :request
    ##config.include Devise::TestHelpers, type: :view
    ##config.include Devise::TestHelpers, type: :helper

    #config.before :suite do
      #DatabaseRewinder.clean_all
    #end

    #config.after :each do
    #end
  #end
#end

#Spork.each_run do
  #FactoryGirl.reload
  #ActiveSupport::Dependencies.clear
  #ActiveRecord::Base.instantiate_observers
  #Rails.application.reload_routes!
#end

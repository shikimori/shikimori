# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'draper/test/rspec_integration'
require 'factory_girl_rails'
require 'factory_girl-seeds'
require 'paperclip/matchers'
require 'shoulda/matchers'
require 'sidekiq/testing'
require 'cancan/matchers'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

Sidekiq::Testing.fake!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = {
    match_requests_on: [:method, :uri, :query, :body],
    record: (ENV['CIRCLE_CI'] ? :none : :new_episodes)
  }
  c.configure_rspec_metadata!
end
Capybara.ignore_hidden_elements = false

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Apipie.record(nil) unless ENV['APIPIE_RECORD']

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
  config.render_views

  #config.infer_base_class_for_anonymous_controllers = false

  # config.include self, type: :serializer, file_path: %r(spec/validators)

  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include JsonResponse, type: :controller
  config.include ControllerResource, type: :controller
  config.include ActionView::TestCase::Behavior, type: :decorator
  config.include Paperclip::Shoulda::Matchers
  config.include Shoulda::Matchers::ActiveModel, type: :validator

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before :each do
    if respond_to?(:controller) && controller
      allow(controller).to receive(:default_url_options)
        .and_return ApplicationController.default_url_options
    end

    Forum.instance_variable_set '@cached', nil

    #RSpec::Mocks.with_temporary_scope do
    allow_any_instance_of(FayePublisher).to receive :run_event_machine
    allow_any_instance_of(FayePublisher).to receive :publish_data
      #allow_any_instance_of(Faye::Client).to receive :publish
    #end
  end

  config.after :each do
    Genres.instance.reset
    Studios.instance.reset
    Publishers.instance.reset

    if respond_to?(:controller) && controller
      # в каких-то случаях params почему-то не очищается
      # словил падение view object спеки от того, что в params лежали данные от
      # предыдущего контроллера
      controller.params.delete_if { true }
    end
  end

  Rails.application.routes.default_url_options = ApplicationController.default_url_options

  Paperclip::Attachment.default_options[:path] =
    "#{Rails.root}/spec/test_files/:class/:id_partition/:style.:extension"

  config.after :suite do
    FileUtils.rm_rf Dir["#{Rails.root}/spec/test_files/"]
  end

  config.before :suite do
    FactoryGirl::SeedGenerator.create :user, id: 500_000

    FactoryGirl::SeedGenerator.create :reviews_forum
    FactoryGirl::SeedGenerator.create :animanga_forum
    FactoryGirl::SeedGenerator.create :contests_forum
    FactoryGirl::SeedGenerator.create :clubs_forum
    FactoryGirl::SeedGenerator.create :cosplay_forum
    FactoryGirl::SeedGenerator.create :offtopic_forum

    FactoryGirl::SeedGenerator.create :offtopic_topic
    FactoryGirl::SeedGenerator.create :site_rules_topic
    FactoryGirl::SeedGenerator.create :faq_topic
    FactoryGirl::SeedGenerator.create :description_of_genres_topic
    FactoryGirl::SeedGenerator.create :ideas_and_suggestions_topic
    FactoryGirl::SeedGenerator.create :site_problems_topic

    ActiveRecord::Base.connection.reset_pk_sequence! :users
    ActiveRecord::Base.connection.reset_pk_sequence! :forums
    ActiveRecord::Base.connection.reset_pk_sequence! :topics
  end
end

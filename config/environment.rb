# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Site::Application.initialize!

require Rails.root.join('lib/string')
require Rails.root.join('lib/i18n_hack')
require Rails.root.join('lib/open_image')
require Rails.root.join('lib/responders/json_responder')
require Rails.root.join('lib/named_logger')
require Rails.root.join('lib/boolean_attribute')

require 'quote_extractor'
require 'acts_as_voteable'
require 'open-uri'

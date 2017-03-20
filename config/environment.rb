# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
require Rails.root.join('lib/string')
require Rails.root.join('lib/i18n_hack')
require Rails.root.join('lib/open_image')
require Rails.root.join('lib/responders/json_responder')
require Rails.root.join('lib/named_logger')

# require 'acts_as_voteable'
# require 'open-uri'

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Site::Application.initialize!

require Rails.root.join('lib', 'string')
require Rails.root.join('lib', 'open_image')

require 'quote_extractor'
require 'acts_as_voteable'
require 'progressbar'

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

# open search
Mime::Type.register_alias 'application/json', :os

# https://stackoverflow.com/questions/67072249/why-does-rails-6-0-x-respond-with-html-when-a-json-view-is-available
# TODO: remove in rails 6.1
Mime::Type.register "*/*", :all

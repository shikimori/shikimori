# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Site::Application.config.secret_token = YAML.load_file(Rails.root.join('config', 'secret_token.yml'))[Rails.env]
Site::Application.config.secret_key_base = YAML.load_file(Rails.root.join('config', 'secret_key_base.yml'))[Rails.env]

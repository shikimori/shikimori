
# Be sure to restart your server when you modify this file.

Site::Application.config.session_store :cookie_store, {
  :key => '_kawai_session',
  :expire_after => 60*60*24*7
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Site::Application.config.session_store :active_record_store

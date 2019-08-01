# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, {
  key: '_kawai_session',
  expire_after: 60*60*24*365*5,
  same_site: :lax,
  domain: :all
}

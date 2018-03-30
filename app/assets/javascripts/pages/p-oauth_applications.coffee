ShikiEditor = require 'views/application/shiki_editor'

page_load 'oauth_applications_new', 'oauth_applications_create', 'oauth_applications_edit', 'oauth_applications_update', ->
  $('.oauth_application_redirect_uri .hint .sample').on 'click', ->
    $('.oauth_application_redirect_uri input').val @innerHTML

  $('.b-shiki_editor').each -> new ShikiEditor @

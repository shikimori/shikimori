page_load 'profiles_ban', ->
  $('.b-form.new_ban').on 'ajax:success', ->
    $.info I18n.t('frontend.pages.p_profiles.page_is_reloading')
    delay(500).then -> location.reload()

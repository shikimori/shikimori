@on 'page:load', 'profiles_ban', ->
  $('.b-form.new_ban').on 'ajax:success', ->
    $.info t('frontend.pages.p_profiles.page_is_reloading')
    location.reload.bind(location).delay(500)


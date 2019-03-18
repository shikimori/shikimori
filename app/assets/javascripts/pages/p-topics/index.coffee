import CollectionSearch from 'views/application/collection_search'
import AnimesMenu from 'views/animes/menu'

pageLoad(
  'topics_index',
  'topics_show',
  'topics_new',
  'topics_edit',
  'topics_create',
  'topics_update',
  ->
    new AnimesMenu('.b-animes-menu') if $('.b-animes-menu').exists()
)

pageLoad 'topics_index', ->
  new CollectionSearch '.b-search'

  $form = $('form.edit_user_preferences')
  $form
    .on 'change', 'input', ->
      $form.submit()

    .on 'ajax:before', ->
      $('.ajax-loading', $form).show()
      $('.reload', $form).hide()

    .on 'ajax:complete', ->
      $('.ajax-loading', $form).hide()
      $('.reload', $form).show()

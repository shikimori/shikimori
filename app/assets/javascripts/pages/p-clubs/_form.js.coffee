@on 'page:load', 'clubs_edit', ->
  $('.b-shiki_editor')
    .shiki_editor()
    .on 'preview:params', ->
      body: $(@).shiki().$textarea.val()
      target_id: 1
      target_type: 'Group'

  $('.anime-suggest, .manga-suggest, .character-suggest').completable_variant()
  $('.moderator-suggest, .admin-suggest').completable_variant()
  $('.kick-suggest, .ban-suggest').completable_variant()

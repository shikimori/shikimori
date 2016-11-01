@on 'page:load', 'clubs_edit', ->
  # description page
  if $('.edit-page.description').exists()
    $('.b-shiki_editor')
      .shiki_editor()
      .on 'preview:params', ->
        body: $(@).view().$textarea.val()
        target_id: 1
        target_type: 'Club'

  # links page
  if $('.edit-page.links').exists()
    $('.anime-suggest, .manga-suggest, .character-suggest').completable_variant()

  # members page
  if $('.edit-page.members').exists()
    $('.moderator-suggest, .admin-suggest').completable_variant()
    $('.kick-suggest, .ban-suggest').completable_variant()

  # styles page
  if $('.edit-page.styles').exists()
    new Styles.Edit '.b-edit_styles'

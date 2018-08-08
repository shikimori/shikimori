import EditStyles from 'views/styles/edit'

page_load 'clubs_edit', ->
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
    $('.anime-suggest').completable_variant()
    $('.manga-suggest').completable_variant()
    $('.ranobe-suggest').completable_variant()
    $('.character-suggest').completable_variant()
    $('.club-suggest').completable_variant()

  # members page
  if $('.edit-page.members').exists()
    $('.moderator-suggest').completable_variant()
    $('.admin-suggest').completable_variant()
    $('.kick-suggest').completable_variant()
    $('.ban-suggest').completable_variant()

  # styles page
  if $('.edit-page.styles').exists()
    new EditStyles '.b-edit_styles'

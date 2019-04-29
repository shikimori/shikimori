import EditStyles from 'views/styles/edit'

pageLoad 'clubs_edit', ->
  # description page
  if $('.edit-page.description').exists()
    $('.b-shiki_editor')
      .shikiEditor()
      .on 'preview:params', ->
        body: $(@).view().$textarea.val()
        target_id: 1
        target_type: 'Club'

  # links page
  if $('.edit-page.links').exists()
    $('.anime-suggest').completableVariant()
    $('.manga-suggest').completableVariant()
    $('.ranobe-suggest').completableVariant()
    $('.character-suggest').completableVariant()
    $('.club-suggest').completableVariant()

  # members page
  if $('.edit-page.members').exists()
    $('.moderator-suggest').completableVariant()
    $('.admin-suggest').completableVariant()
    $('.kick-suggest').completableVariant()
    $('.ban-suggest').completableVariant()

  # styles page
  if $('.edit-page.styles').exists()
    new EditStyles '.b-edit_styles'

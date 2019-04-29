pageLoad 'club_topics_new', 'club_topics_edit', 'club_topics_create', 'club_topics_update', ->
  $form = $ '.b-form.edit_topic, .b-form.new_topic'
  $('.b-shiki_editor', $form).shikiEditor()

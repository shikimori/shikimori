@on 'page:load', 'topics_new', 'topics_edit', 'topics_create', 'topics_update', ->
  $('.b-shiki_editor').shiki_editor()

  $('.topic_linked .cleanup').on 'click', ->
    $('.topic_linked .topic-link, .topic_linked .topic-video').empty()
    $('#topic_linked_id').val('')
    $('#topic_linked_type').val('')
    $('#topic_linked').val('')

  $('#topic_linked').completable()
    .on 'autocomplete:success', (e, entry) ->
      $('#topic_linked_id').val(entry.id)
      $('#topic_linked_type').val(if is_anime() then 'Anime' else 'Manga')
      @value = ''

      type = if is_anime() then 'anime' else 'manga'
      $('.topic_linked .topic-link')
        .html("<a href='/#{type}s/#{entry.id}' class='bubbled'>#{entry.name}</a>")
        .process()

      $('.topic_linked .topic-video').html "<a href='/#{type}s/#{entry.id}/edit/videos' target='_blank'>добавить видео</a>"

is_anime = ->
  $('#topic_type').val() == 'AnimeNews'

is_manga = ->
  $('#topic_type').val() == 'MangaNews'

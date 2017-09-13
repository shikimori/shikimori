page_load 'anime_video_authors_index', ->
  $('.anime-suggest')
    .completable_variant()
    .on 'autocomplete:success', (e, entry) ->
      $('#anime_id').val entry.id
      $(e.target).closest('form').submit()

page_load 'anime_video_authors_none', ->
  $('.anime-suggest')
    .completable_variant()
    .on 'autocomplete:success', (e, entry) ->
      $('#anime_id').val entry.id
      $(e.target).closest('form').submit()

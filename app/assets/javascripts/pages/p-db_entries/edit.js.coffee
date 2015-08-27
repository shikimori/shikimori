@on 'page:load', '.db_entries-edit_field', ->
  if $('.edit-page.description').exists()
    $editor = $('.b-shiki_editor')
    $editor
      .shiki_editor()
      .on 'preview:params', ->
        body: $(@).shiki().$textarea.val()
        target_id: $editor.data('target_id')
        target_type: $editor.data('target_type')

  if $('.edit-page.screenshots').exists()
    $('.c-screenshot').shiki_image()

    $screenshots_positioner = $('.screenshots-positioner')
    $('form', $screenshots_positioner).on 'submit', ->
      $images = $('.c-screenshot:not(.deleted) img', $screenshots_positioner)
      ids = $images.map -> $(@).data('id')
      $screenshots_positioner.find('#entry_ids').val $.makeArray(ids).join(',')

    $screenshots_uploader = $('.screenshots-uploader')
    $screenshots_uploader.shikiFile
        progress: $screenshots_uploader.find(".b-upload_progress")
        input: $screenshots_uploader.find("input[type=file]")
        maxfiles: 250

      .on 'upload:after', ->
        $screenshots_uploader.find('.thank-you').show()

      .on 'upload:success', (e, response) ->
        $(response.html)
          .appendTo($('.cc', $screenshots_uploader))
          .shiki_image()

  if $('.edit-page.videos').exists()
    $('.videos-deleter .b-video').image_editable()

  if $('.edit-page.tags').exists()
    $('#anime_tags, #manga_tags, #character_tags')
      .completable()
      .on 'autocomplete:success autocomplete:text', (e, result) ->
        @value = if Object.isString(result) then result else result.value
        $('.b-gallery').data(tags: @value)
        $('.b-gallery').shiki().refresh()

    $('.b-gallery').imageboard()

  if $('.edit-page.genres').exists()
    $current_genres = $('.c-current_genres').children().last()
    $all_genres = $('.c-all_genres').children().last()

    $current_genres.on 'click', '.remove', ->
      $(@).closest('.genre')
        .detach()
        .appendTo($all_genres)
        .yellowFade()

    $current_genres.on 'click', '.up', ->
      $genre = $(@).closest('.genre')
      $prior = $genre.prev()

      $genre
        .detach()
        .insertBefore($prior)
        .yellowFade()

    $current_genres.on 'click', '.down', ->
      $genre = $(@).closest('.genre')
      $next = $genre.next()

      $genre
        .detach()
        .insertAfter($next)
        .yellowFade()

    $all_genres.on 'click', '.name', ->
      $(@).closest('.genre')
        .detach()
        .appendTo($current_genres)
        .yellowFade()

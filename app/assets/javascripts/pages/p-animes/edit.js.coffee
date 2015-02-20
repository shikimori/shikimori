@on 'page:load', 'animes_edit', 'mangas_edit', ->
  if $('.edit-page.description').exists()
    $('.b-shiki_editor')
      .shiki_editor()
      .on 'preview:params', ->
        body: $(@).shiki().$textarea.val()
        target_id: $('#change_item_id').val()
        target_type: $('#change_model').val()

  if $('.edit-page.screenshots').exists()
    $('.c-screenshot').shiki_image()

    $screenshots_positioner = $('.screenshots-positioner')
    $('form', $screenshots_positioner).on 'submit', ->
      $images = $('.c-screenshot:not(.deleted) img', $screenshots_positioner)
      ids = $images.map -> $(@).data('id')
      $screenshots_positioner.find('#user_change_value').val $.makeArray(ids).join(',')

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

  if $('.edit-page.video').exists()
    $('form.new_video').on 'ajax:success', (e) ->
      Turbolinks.visit.bind(Turbolinks, location.href).delay(500)
      $root.image_editable()

    $('.videos-deleter .b-video').image_editable()

  if $('.edit-page.tags').exists()
    $('#user_change_value')
      .completable()
      .on 'autocomplete:success autocomplete:text', (e, result) ->
        @value = if Object.isString(result) then result else result.value
        $('.b-gallery').data(tags: @value)
        $('.b-gallery').shiki().refresh()

    $('.b-gallery').imageboard()

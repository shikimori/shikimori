page_load '.db_entries-edit_field', ->
  $description = $('.edit-page.description_ru, .edit-page.description_en')

  if $description.exists()
    $editor = $('.b-shiki_editor')
    $editor
      .shiki_editor()
      .on 'preview:params', ->
        body: $(@).view().$textarea.val()
        target_id: $editor.data('target_id')
        target_type: $editor.data('target_type')

    $('form', $description).on 'submit', ->
      $form = $(@)
      new_description = (text, source) ->
        if source
          "#{text}[source]#{source}[/source]"
        else
          "#{text}"

      $('[id$=_description_ru]', $form).val(
        new_description(
          $('[id$=_description_ru_text]', $form).val(),
          $('[id$=_description_ru_source]', $form).val()
        )
      )
      $('[id$=_description_en]', $form).val(
        new_description(
          $('[id$=_description_en_text]', $form).val(),
          $('[id$=_description_en_source]', $form).val()
        )
      )

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
    $gallery = $('.b-gallery')
    gallery_html = $gallery.html()

    if $gallery.data 'tags'
      new Images.ImageboardGallery $gallery

    $('#anime_tags, #manga_tags, #character_tags')
      .completable()
      .on 'autocomplete:success autocomplete:text', (e, result) ->
        @value = if Object.isString(result) then result else result.value
        $gallery.data(tags: @value)
        $gallery.html(gallery_html)
        new Images.ImageboardGallery $gallery

  if $('.edit-page.genres').exists()
    $current_genres = $('.c-current_genres').children().last()
    $all_genres = $('.c-all_genres').children().last()

    $current_genres.on 'click', '.remove', ->
      $genre = $(@).closest('.genre').remove()

      $all_genres.find('#' + $genre.attr('id'))
        .removeClass('included')
        .yellow_fade()

    $current_genres.on 'click', '.up', ->
      $genre = $(@).closest('.genre')
      $prior = $genre.prev()

      $genre
        .detach()
        .insertBefore($prior)
        .yellow_fade()

    $current_genres.on 'click', '.down', ->
      $genre = $(@).closest('.genre')
      $next = $genre.next()

      $genre
        .detach()
        .insertAfter($next)
        .yellow_fade()

    $all_genres.on 'click', '.name', ->
      $genre = $(@).closest('.genre')

      if $genre.hasClass 'included'
        $current_genres.find("##{$genre.attr 'id'} .remove").click()
        return

      $genre.clone()
        .appendTo($current_genres)
        .yellow_fade()

      $genre.addClass('included')

    $('form.new_version').on 'submit', ->
      $item_diff = $('.item_diff')

      new_ids = $current_genres
        .children()
        .map -> parseInt @id
        .toArray()
      current_ids = $item_diff.data('current_ids')

      diff = genres: [current_ids, new_ids]
      $item_diff.find('input').val JSON.stringify(diff)

  if $('.edit-page.external_links').exists()
    require.ensure [], ->
      init_app(
        require('vue/instance').Vue,
        require('vue/components/external_links/external_links.vue'),
        require('vue/stores').external_links,
      )

init_app = (Vue, ExternalLinks, store) ->
  external_links = $('#vue_external_links').data('external_links')
  kind_options = $('#vue_external_links').data('kind_options')

  store.state.external_links = external_links

  new Vue
    el: '#vue_external_links'
    store: store
    render: (h) -> h(ExternalLinks, props: { kind_options: kind_options })

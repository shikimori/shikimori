@on 'page:load', 'clubs_edit', ->
  suggests_selector = '.anime-suggest,.manga-suggest,.character-suggest,.moderator-suggest,.admin-suggest,.kick-suggest,.ban-suggest'
  $('.b-shiki_editor').shiki_editor()

  $(suggests_selector)
    .completable()
    .on 'autocomplete:success', (e, entry) ->
      $variants = $(@).parent().find('.variants')
      variant_name = $(@).data('variant_name')
      return if $variants.find("[value=\"#{entry.id}\"]").exists()

      $entry = $(
        '<div class="variant">' +
          '<input type="checkbox" name="'+variant_name+'" value="'+entry.id+'" checked="true" />' +
          '<a href="'+entry.url+'" class="bubbled">'+entry.name+'</a>' +
        '</div>')
        .appendTo($variants)
        .process()

      @value = ''

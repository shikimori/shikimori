# клик по блоку загрузки
$(document).on 'click', '.click-loader', ->
  $this = $(@)
  return if $this.data 'locked'

  $this.data locked: true
  $this.trigger 'ajax:before'

  $this
    .data(html: $this.html())
    .html("<div class='ajax-loading vk-like' title='#{t('frontend.blocks.click_loader.loading')}' />")

  method = if $this.data('format') == 'json' then 'getJSON' else 'get'

  $[method]($this.data 'href').success (data, status, xhr) ->
    $this
      .data(locked: false)
      .trigger('ajax:success', data)

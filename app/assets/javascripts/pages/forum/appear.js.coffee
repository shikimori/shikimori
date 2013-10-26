$ ->
  # пометака комментариев прочитанными
  $('.comment-new .appear-marker').appear()

# пометка комментариев прочитанным и их последующее скрытие
$('.comment-new .appear-marker').live 'appear', (e, $appeared, by_click) ->
  $nodes = ($appeared || $(@)).not -> $(@).data 'disabled'

  $appear_blocks = $nodes.parents('.appear-block').removeClass('comment-new')
  $markers = $appear_blocks.find('.new-marker')
  ids = _.map($nodes, (v) ->
    v.className.match(/appear-((\w+-)?\d+)/)[1]
  )
  $.post $(@).data('href'), "ids=#{ids.join(",")}"

  _.delay ->
    $markers.css opacity: 0

    _.delay ->
      $markers.hide()
    , 750
  , (if by_click then 1 else 1500)


# по клику на 'новое' пометка прочитанным
$('.appear-block .new-marker').live 'click', ->
  $marker = $(@).parents('.appear-block').find('.appear-marker')
  $marker.trigger 'appear', [$marker, true]

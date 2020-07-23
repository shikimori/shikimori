import cookies from 'js-cookie'

$(document).on 'click', '.collapse', (e, custom) ->
  is_hide = $(@).children('.action').html().match(/свернуть|спрятать|collapse|hide/)
  $(@).toggleClass 'triggered', is_hide

  # блок-заглушка, в которую сворачивается контент
  $placeholder = $(@).next()
  $placeholder = $placeholder.next() unless $placeholder.hasClass('collapsed')

  # контент, убираемый под спойлер
  $hideable = $placeholder.next()

  # если в $hideable ничего, значит надо идти на уровень выше и брать next оттуда
  $hideable = $(@).parent().next() unless $hideable.exists()

  # скрываем не только следующий элемент, но и все последующие с классом collapse-merged
  while $hideable.last().next().hasClass('collapse-merged')
    $hideable = $hideable.add($hideable.last().next())

  # при этом игнорируем то, что имеет класс collapse-ignored
  $hideable = $hideable.filter(':not(.collapse-ignored)')  if $hideable.length > 1
  if is_hide
    $placeholder.show()
    $hideable.hide()
  else
    $hideable.show()
    $placeholder.hide()

  # корректный текст для кнопки действия
  $(@).children('.action').html ->
    $action = $(@)

    if $action.hasClass('half-hidden')
      if is_hide
        $action.hide()
      else
        $action.show()

    if is_hide
      $action.html()
        .replace('свернуть', 'развернуть')
        .replace('спрятать', 'показать')
        .replace('hide', 'show')
        .replace('collapse', 'expand')
    else
      $action.html()
        .replace('развернуть', 'свернуть')
        .replace('показать', 'спрятать')
        .replace('show', 'hide')
        .replace('expand', 'collapse')

  unless custom
    id = $(@).attr('id')
    if id && id != '' && id.indexOf('-') != -1
      name = id.split('-').slice(1).join('-') + ';'
      collapses = cookies.get('collapses') || ''

      if is_hide && collapses.indexOf(name) == -1
        cookies.set 'collapses', collapses + name,
          expires: 730
          path: '/'

      else if !is_hide && collapses.indexOf(name) != -1
        cookies.set 'collapses', collapses.replace(name, ''),
          expires: 730
          path: '/'

  $placeholder.next().trigger 'show'

  # всем картинкам внутри спойлера надо заново проверить высоту
  #$hideable.find('img').addClass 'check-width'

# клик на "свернуть"
$(document).on 'click', '.collapsed', ->
  $trigger = $(@).prev()
  $trigger = $trigger.prev() unless $trigger.hasClass('collapse')
  $trigger.trigger('click')

$(document).on 'click', '.hide-expanded', ->
  $(@).parent().prev().trigger('click')

# клик на содержимое спойлера
$(document).on 'click', '.spoiler.target', ->
  return unless $(@).hasClass('dashed')

  $(@).hide().prev().show().prev().show()

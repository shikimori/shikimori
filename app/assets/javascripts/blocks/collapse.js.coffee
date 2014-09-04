# TODO: выпилить отсюда все упомянания о спойлерах
# сворачивание/разворачивание collapse блоков по клику
$(document).on 'click', '.collapse', (e, custom) ->
  $this = $(this)
  is_hide = $this.children('.action').html().match(/свернуть/)
  #in_comment = $this.parents('.topic-block,.comment-block,.description').length > 0

  # блок-заглушка, в которую сворачивается контент
  $placeholder = $this.next()
  $placeholder = $placeholder.next() unless $placeholder.hasClass('collapsed')

  # еонтент, убираемый под спойлер
  $hideable = $placeholder.next()

  # если в $hideable ничего, значит надо идти на уровень выше и брать next оттуда
  $hideable = $this.parent().next() unless $hideable.exists()

  # если внутри спойлера картинки, то отображение дефолтное
  in_comment = $hideable.find('img').not('.smiley').exists()

  # если спойлер внутри комментария, то у него особое отображение
  if in_comment
    $hideable.addClass('dashed').attr title: 'свернуть спойлер'

  # скрываем не только следующий элемент, но и все последующие с классом collapse-merged
  $hideable = $hideable.add($hideable.last().next())  while $hideable.last().next().hasClass('collapse-merged')

  # при этом игнорируем то, что имеет класс collapse-ignored
  $hideable = $hideable.filter(':not(.collapse-ignored)')  if $hideable.length > 1
  if is_hide
    $placeholder.show()
    $hideable.hide()
  else
    # при показе спойлера можем просто показать его содержимое, открыв элемент
    #if !$hideable.data('href')
    $hideable.show()
    $placeholder.hide()
    #else
      # а можем подгрузить контент с сервера
      #$placeholder.html('<img src="/images/loading.gif" alt="загрузка..." title="загрузка..." />');
      #$hideable.load($hideable.data('href'), function() {
        #$placeholder.hide();
      #});
      #$hideable.data('href', null);

  # корректный текст для кнопки действия
  $this.children('.action').html ->
    $this = $(this)
    if $this.hasClass('half-hidden')
      if is_hide
        $this.hide()
      else
        $this.show()
    if in_comment
      ""
    else
      if is_hide
        $this.html().replace('свернуть', 'развернуть')
      else
        $this.html().replace('развернуть', 'свернуть')

  unless custom
    id = $this.attr("id")
    if id and id isnt "" and id.indexOf("-") isnt -1
      name = id.split("-").slice(1).join("-") + ";"
      collapses = $.cookie("collapses") or ""
      if is_hide and collapses.indexOf(name) is -1
        $.cookie "collapses", collapses + name,
          expires: 730
          path: "/"

      else if not is_hide and collapses.indexOf(name) isnt -1
        $.cookie "collapses", collapses.replace(name, ""),
          expires: 730
          path: "/"

  $placeholder.next().trigger "show"

  # всем картинкам внутри спойлера надо заново проверить высоту
  $hideable.find('img').addClass 'check-width'
  process_current_dom()

# клик на "свернуть"
$(document).on 'click', '.collapsed', ->
  $trigger = $(@).prev()
  $trigger = $trigger.prev() unless $trigger.hasClass('collapse')
  $trigger.trigger('click')

# клик на содержимое спойлера
$(document).on 'click', '.spoiler.target', ->
  return unless $(@).hasClass('dashed')
  $(@).hide().prev().show().prev().show()


@on 'page:load', '.clubs', ->
  $suggest = $('.new_group_invite .suggest').completable 'Имя пользователя'

  #invite_placeholder = 'укажите имя пользователя'
  ## приглашение в группу
  $('.invite .show').on 'click', (e) ->
    if $suggest.is(':visible')
      $('.new_group_invite').animated_collapse()
    else
      $('.new_group_invite').animated_expand()
      $suggest.focus.bind($suggest).delay()

  $suggest.on 'autocomplete:success', (e, id, text, label) ->
    return if !id || !text

    $('.new_group_invite #group_invite_dst_id').val(id)
    $('.new_group_invite')
      .animated_collapse()
      .submit()

    #$input = $('.send-invite')
    #if $input.hasClass('hidden')
      #$(@).children().toggleClass('hidden')
      #$input.val invite_placeholder unless $input.val()
      #$input.focus().select()

  #$('.send-invite')
    #.on 'keydown', (e) ->
      #if e.keyCode is 27
        #$(@).parent().children().toggleClass('hidden')

    #.on 'keypress blur', (e) ->
      #$this = $(this)
      #if (e.which == 13 || e.type == 'focusout') && !$this.hasClass('hidden')
        #if @value != "" && @value != invite_placeholder
          #$this.callRemote()
        #else
          #$this.parent().children().toggleClass('hidden')

    #.on 'ajax:loading', (e, data) ->
      #data.ajax.url = data.ajax.url.replace('$nickname', @value)

    #.on 'ajax:success', (e, data) ->
      #$(@).parent().children().toggleClass('hidden')
      #@value = ''

    #.on 'ajax:failure', ->
      #$(@).parent().children().toggleClass('hidden')


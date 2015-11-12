@on 'page:load', 'dashboards_show', ->
  $('.user_list .switch').on 'click', ->
    $(@)
      .closest('.list-type')
      .toggleClass('hidden')
        .siblings('.list-type')
        .toggleClass('hidden')

  $('.c-content .options .option').on 'click', ->
    $(@)
      .addClass('selected')
        .siblings()
        .removeClass('selected')

    $('.c-content .slides .slide')
      .eq($(@).index())
      .removeClass('hidden')
        .siblings()
        .addClass('hidden')

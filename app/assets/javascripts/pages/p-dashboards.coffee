@on 'page:load', 'dashboards_show', ->
  $('.user_list .switch').on 'click', ->
    $(@)
      .closest('.list-type')
      .toggleClass('hidden')
        .siblings('.list-type')
        .toggleClass('hidden')

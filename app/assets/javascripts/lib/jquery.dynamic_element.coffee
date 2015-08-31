(($) ->
  $.fn.extend dynamic_element: ->
    @each ->
      @classList.remove 'to-process'

      for processor in @attributes['data-dynamic'].value.split(',')
        switch processor
          when 'cutted_covers' then new CuttedCovers(@)
          when 'authorized' then new AuthorizedAction(@)
          when 'html5_video' then new Html5Video(@)
          else
            console.error "unexpected processor: #{processor}"
) jQuery

(($) ->
  $.fn.extend dynamic_element: ->
    @each ->
      @classList.remove 'to-process'

      for processor in @attributes['data-dynamic'].value.split(',')
        switch processor
          when 'cutted_covers' then new CuttedCovers(@)
          when 'authorized' then new AuthorizedAction(@)
          when 'day_registered' then new DayRegisteredAction(@)
          when 'week_registered' then new WeekRegisteredAction(@)
          when 'html5_video' then new Html5Video(@)
          when 'abuse_request' then new AbuseRequest(@)
          when 'desktop_ad' then new DesktopAd(@)
          when 'user_rate' then new UserRate(@)
          else
            console.error "unexpected processor: #{processor}"
) jQuery

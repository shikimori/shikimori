using 'DynamicElements'
class DynamicElements.Parser
  constructor: ($nodes) ->
    $nodes.each ->
      @classList.remove 'to-process'

      for processor in @attributes['data-dynamic'].value.split(',')
        switch processor
          when 'cutted_covers' then new DynamicElements.CuttedCovers(@)
          when 'authorized' then new DynamicElements.AuthorizedAction(@)
          when 'day_registered' then new DynamicElements.DayRegisteredAction(@)
          when 'week_registered' then new DynamicElements.WeekRegisteredAction(@)
          when 'html5_video' then new DynamicElements.Html5Video(@)
          when 'abuse_request' then new DynamicElements.AbuseRequest(@)
          when 'desktop_ad' then new DynamicElements.DesktopAd(@)
          when 'user_rate'
            if @attributes['data-extended'].value == 'true'
              new DynamicElements.UserRates.Extended(@)
            else
              new DynamicElements.UserRates.Button(@)
          else
            console.error "unexpected processor: #{processor}"

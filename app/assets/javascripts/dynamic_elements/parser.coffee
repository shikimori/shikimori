using 'DynamicElements'
class DynamicElements.Parser
  @PENDING_CLASS = 'to-process'

  constructor: ($nodes) ->
    $nodes.each (index, node) =>
      node.classList.remove DynamicElements.Parser.PENDING_CLASS

      for processor in node.attributes['data-dynamic'].value.split(',')
        switch processor
          when 'cutted_covers' then new DynamicElements.CuttedCovers(node)
          when 'text_annotated' then new DynamicElements.TextAnnotated(node)
          when 'authorized' then new DynamicElements.AuthorizedAction(node)
          when 'day_registered' then new DynamicElements.DayRegisteredAction(node)
          when 'week_registered' then new DynamicElements.WeekRegisteredAction(node)
          when 'html5_video' then new DynamicElements.Html5Video(node)
          when 'abuse_request' then new DynamicElements.AbuseRequest(node)
          when 'desktop_ad' then new DynamicElements.DesktopAd(node)

          when 'code_highlight' then new DynamicElements.CodeHighlight(node)

          when 'forum' then new DynamicElements.Forum(node)
          when 'topic' then new DynamicElements.Topic(node)
          when 'comment' then new DynamicElements.Comment(node)
          when 'message' then new DynamicElements.Message(node)
          when 'short_dialog' then new DynamicElements.ShortDialog(node)
          when 'full_dialog' then new DynamicElements.FullDialog(node)

          when 'user_rate'
            if node.attributes['data-extended'].value == 'true'
              new DynamicElements.UserRates.Extended(node)
            else
              new DynamicElements.UserRates.Button(node)

          else
            console.error "unexpected processor: #{processor}"

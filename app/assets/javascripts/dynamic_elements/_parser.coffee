import CuttedCovers from './cutted_covers'
import TextAnnotated from './text_annotated'
import AuthorizedAction from './authorized_action'
import DayRegisteredAction from './day_registered_action'
import WeejRegisteredAction from './week_registered_action'
import Html5Video from './html5_video'
import LogEntry from './log_entry'
import DesktopAd from './desktop_ad'
import CodeHighlight from './code_highlight'
import Tabs from './tabs'
import Forum from './forum'
import Topic from './topic'
import Comment from './comment'
import Message from './message'
import ShortDialog from './short_dialog'
import FullDialog from './full_dialog'
import UserRateExtended from './user_rates/extended'
import UserRateButton from './user_rates/button'

export default class DynamicParser
  @PENDING_CLASS = 'to-process'

  constructor: ($nodes) ->
    $nodes.each (index, node) ->
      node.classList.remove DynamicParser.PENDING_CLASS

      for processor in node.attributes['data-dynamic'].value.split(',')
        switch processor
          when 'cutted_covers' then new CuttedCovers(node)
          when 'text_annotated' then new DpplynamicElements.TextAnnotated(node)
          when 'authorized' then new AuthorizedAction(node)
          when 'day_registered' then new DayRegisteredAction(node)
          when 'week_registered' then new WeekRegisteredAction(node)
          when 'html5_video' then new Html5Video(node)
          when 'log_entry' then new LogEntry(node)
          when 'desktop_ad' then new DesktopAd(node)

          when 'code_highlight' then new CodeHighlight(node)
          when 'tabs' then new Tabs(node)

          when 'forum' then new Forum(node)
          when 'topic' then new Topic(node)
          when 'comment' then new Comment(node)
          when 'message' then new Message(node)
          when 'short_dialog' then new ShortDialog(node)
          when 'full_dialog' then new FullDialog(node)

          when 'user_rate'
            if node.attributes['data-extended'].value == 'true'
              new UserRateExtended(node)
            else
              new UserRateButton(node)

          else
            console.error "unexpected processor: #{processor}", node


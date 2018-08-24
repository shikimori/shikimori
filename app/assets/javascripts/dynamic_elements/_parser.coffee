import CuttedCovers from './cutted_covers'
import TextAnnotated from './text_annotated'
import AuthorizedAction from './authorized_action'
import DayRegisteredAction from './day_registered_action'
import WeekRegisteredAction from './week_registered_action'
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

PENDING_CLASS = 'to-process'

export default class DynamicParser
  constructor: ($nodes) ->
    $nodes.each (index, node) =>
      node.classList.remove DynamicParser.PENDING_CLASS

      for processor in node.attributes['data-dynamic'].value.split(',')
        if @[processor]
          @[processor](node)
        else
          console.error "unexpected processor: #{processor}", node

  cutted_covers: (node) ->
    new CuttedCovers(node)

  text_annotated: (node) ->
    new TextAnnotated(node)

  authorized: (node) ->
    new AuthorizedAction(node)

  day_registered: (node) ->
    new DayRegisteredAction(node)

  week_registered: (node) ->
    new WeekRegisteredAction(node)

  html5_video: (node) ->
    new Html5Video(node)

  log_entry: (node) ->
    new LogEntry(node)

  desktop_ad: (node) ->
    new DesktopAd(node)

  code_highlight: (node) ->
    new CodeHighlight(node)

  tabs: (node) ->
    new Tabs(node)

  forum: (node) ->
    new Forum(node)

  topic: (node) ->
    new Topic(node)

  comment: (node) ->
    new Comment(node)

  message: (node) ->
    new Message(node)

  short_dialog: (node) ->
    new ShortDialog(node)

  full_dialog: (node) ->
    new FullDialog(node)

  user_rate: (node) ->
    if node.attributes['data-extended'].value == 'true'
      new UserRateExtended(node)
    else
      new UserRateButton(node)

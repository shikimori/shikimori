import CuttedCovers from './cutted_covers';
import TextAnnotated from './text_annotated';
import AuthorizedAction from './authorized_action';
import DayRegisteredAction from './day_registered_action';
import WeekRegisteredAction from './week_registered_action';
import Html5Video from './html5_video';
import LogEntry from './log_entry';
import DesktopAd from './desktop_ad';
import CodeHighlight from './code_highlight';
import Tabs from './tabs';
import Forum from './forum';
import Topic from './topic';
import Comment from './comment';
import Message from './message';
import ShortDialog from './short_dialog';
import FullDialog from './full_dialog';
import UserRateExtended from './user_rates/extended';
import UserRateButton from './user_rates/button';

export default class DynamicParser {
  static PENDING_CLASS = 'to-process';

  constructor($nodes) {
    $nodes.each((index, node) => {
      node.classList.remove(DynamicParser.PENDING_CLASS);

      node.attributes['data-dynamic'].value.split(',').forEach(type => {
        const processor = type.camelize(false);

        if (this[processor]) {
          this[processor](node);
        } else {
          console.error(`unexpected processor: ${processor}`, node);
        }
      });
    });
  }

  cuttedCovers(node) {
    new CuttedCovers(node);
  }

  textAnnotated(node) {
    new TextAnnotated(node);
  }

  authorized(node) {
    new AuthorizedAction(node);
  }

  dayRegistered(node) {
    new DayRegisteredAction(node);
  }

  weekRegistered(node) {
    new WeekRegisteredAction(node);
  }

  html5Video(node) {
    new Html5Video(node);
  }

  logEntry(node) {
    new LogEntry(node);
  }

  desktopAd(node) {
    new DesktopAd(node);
  }

  codeHighlight(node) {
    new CodeHighlight(node);
  }

  tabs(node) {
    new Tabs(node);
  }

  forum(node) {
    new Forum(node);
  }

  topic(node) {
    new Topic(node);
  }

  comment(node) {
    new Comment(node);
  }

  message(node) {
    new Message(node);
  }

  shortDialog(node) {
    new ShortDialog(node);
  }

  fullDialog(node) {
    new FullDialog(node);
  }

  userRate(node) {
    if (node.attributes['data-extended'].value === 'true') {
      new UserRateExtended(node);
    } else {
      new UserRateButton(node);
    }
  }
}

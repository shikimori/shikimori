import AuthorizedAction from './authorized_action';
import Clickloaded from './clickloaded';
import CodeHighlight from './code_highlight';
import Comment from './comment';
import CuttedCovers from './cutted_covers';
import DayRegisteredAction from './day_registered_action';
import DesktopAd from './desktop_ad';
import Forum from './forum';
import FullDialog from './full_dialog';
import Html5Video from './html5_video';
import LogEntry from './log_entry';
import Message from './message';
import Postloaded from './postloaded';
import ShortDialog from './short_dialog';
import Swiper from './swiper';
import Tabs from './tabs';
import TextAnnotated from './text_annotated';
import Topic from './topic';
import UserRateButton from './user_rates/button';
import UserRateExtended from './user_rates/extended';
import Wall from './wall';
import WeekRegisteredAction from './week_registered_action';

import { isTablet, isMobile } from 'helpers/mobile_detect';

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

  authorized(node) {
    new AuthorizedAction(node);
  }

  clickloaded(node) {
    new Clickloaded(node);
  }

  codeHighlight(node) {
    new CodeHighlight(node);
  }

  comment(node) {
    new Comment(node);
  }

  cuttedCovers(node) {
    new CuttedCovers(node);
  }

  dayRegistered(node) {
    new DayRegisteredAction(node);
  }

  desktopAd(node) {
    new DesktopAd(node);
  }

  forum(node) {
    new Forum(node);
  }

  fullDialog(node) {
    new FullDialog(node);
  }

  html5Video(node) {
    new Html5Video(node);
  }

  logEntry(node) {
    new LogEntry(node);
  }

  message(node) {
    new Message(node);
  }

  postloaded(node) {
    new Postloaded(node);
  }

  shortDialog(node) {
    new ShortDialog(node);
  }

  swiper(node) {
    new Swiper(node);
  }


  tabs(node) {
    new Tabs(node);
  }

  topic(node) {
    new Topic(node);
  }

  userRate(node) {
    if (node.attributes['data-extended'].value === 'true') {
      new UserRateExtended(node);
    } else {
      new UserRateButton(node);
    }
  }

  wall(node) {
    if (isMobile() || isTablet()) {
      node.classList.remove('b-shiki_wall');
      node.classList.add('b-shiki_swiper');
      new Swiper(node);
    } else {
      new Wall(node);
    }
  }

  weekRegistered(node) {
    new WeekRegisteredAction(node);
  }
}

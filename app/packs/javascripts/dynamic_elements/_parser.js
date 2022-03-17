import Clickloaded from './clickloaded';
import CodeHighlight from './code_highlight';
import Comment from './comment';
import DayRegisteredAction from './day_registered_action';
import DesktopAd from './desktop_ad';
import Forum from './forum';
import FullDialog from './full_dialog';
import Html5Video from './html5_video';
import LogEntry from './log_entry';
import Message from './message';
import NotImplementedYetAction from './not_implemented_yet_action';
import Postloaded from './postloaded';
import Critique from './critique';
import Review from './review';
import ShikiEditor from './shiki_editor';
import ShikiEditorV2 from './shiki_editor_v2';
import ShortDialog from './short_dialog';
import SpoilerBlock from './spoiler_block';
import SpoilerInline from './spoiler_inline';
import Swiper from './swiper';
import Switcher from './switcher';
import Tabs from './tabs';
import TextAnnotated from './text_annotated';
import Topic from './topic';
import UserRateButton from './user_rates/button';
import UserRateExtended from './user_rates/extended';
import WallOrSwiper from './wall_or_swiper';
import { AuthorizedAction } from './authorized_action';
import { CuttedCovers } from './cutted_covers';
import WeekRegisteredAction from './week_registered_action';

export default class DynamicParser {
  static PENDING_CLASS = 'to-process';

  constructor($nodes) {
    $nodes.each((index, node) => {
      // DynamicParser can be called recursively
      // For example at dynamic_elements/topic `this.editor = this.$editor.process().view();`
      if (!node.classList.contains(DynamicParser.PENDING_CLASS)) { return; }

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

  async alignedPosters(node) {
    const { AlignedPosters } = await import(
      /* webpackChunkName: "aligned_posters" */ './aligned_posters'
    );
    new AlignedPosters(node);
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

  notImplementedYetAction(node) {
    new NotImplementedYetAction(node);
  }

  postloaded(node) {
    new Postloaded(node);
  }

  shortDialog(node) {
    new ShortDialog(node);
  }

  shikiEditor(node) {
    new ShikiEditor(node);
  }

  shikiEditorV2(node) {
    new ShikiEditorV2(node);
  }

  swiper(node) {
    new Swiper(node);
  }

  switcher(node) {
    new Switcher(node);
  }

  spoilerBlock(node) {
    new SpoilerBlock(node);
  }

  spoilerInline(node) {
    new SpoilerInline(node);
  }

  review(node) {
    new Review(node);
  }

  critique(node) {
    new Critique(node);
  }

  tabs(node) {
    new Tabs(node);
  }

  textAnnotated(node) {
    new TextAnnotated(node);
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
    new WallOrSwiper(node);
  }

  weekRegistered(node) {
    new WeekRegisteredAction(node);
  }
}

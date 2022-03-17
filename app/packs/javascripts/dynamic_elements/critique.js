import { bind } from 'shiki-decorators';
import Topic from './topic';
import checkHeight from '@/utils/check_height';
import { imagePromiseFinally } from '@/utils/load_image';


export default class Critique extends Topic {
  @bind
  async _checkHeight() {
    const $entryCover = this.$('.critique-entry_cover img');

    if (!$entryCover.length) {
      return super._checkHeight();
    }

    await imagePromiseFinally($entryCover[0]);

    const imageHeight = $entryCover.height();
    const readMoreHeight = 13 + 5; // 5px - read_more offset

    if (imageHeight > 0) {
      checkHeight(this.$('.body-inner'), {
        maxHeight: imageHeight - readMoreHeight,
        collapsedHeight: imageHeight - readMoreHeight,
        expandHtml: ''
      });
    }
  }
}

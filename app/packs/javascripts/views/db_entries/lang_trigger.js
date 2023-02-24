import View from '@/views/application/view';
import { bind, memoize } from 'shiki-decorators';

export class LangTrigger extends View {
  initialize() {
    this.on('click', this.toggle);
  }

  @memoize
  get $description() {
    return this.$node.closest('.c-description');
  }

  @memoize
  get $other() {
    return this.$description.find('.description-other');
  }

  @memoize
  get $current() {
    return this.$description.find('.description-current');
  }

  @memoize
  get $changes() {
    return this.$description.find('.changes');
  }

  @bind
  toggle() {
    if (this.$other.is(':visible')) {
      this.eng();
    } else {
      this.rus();
    }
  }

  eng() {
    this.$other.hide();
    this.$current.show();
    this.$changes.show();
    this.$node.children().html('eng');
  }

  rus() {
    this.$other.show();
    this.$current.hide();
    this.$changes.hide();
    this.$node.children().html('рус');
  }
}

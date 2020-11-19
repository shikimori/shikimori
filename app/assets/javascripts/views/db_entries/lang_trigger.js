import View from 'views/application/view';
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
  get $english() {
    return this.$description.find('.english');
  }

  @memoize
  get $russian() {
    return this.$description.find('.russian');
  }

  @memoize
  get $changes() {
    return this.$description.find('.changes');
  }

  @bind
  toggle() {
    if (this.$english.is(':visible')) {
      this.eng()
    } else {
      this.rus();
    }
  }

  eng() {
    this.$english.hide();
    this.$russian.show();
    this.$changes.show();
    this.$node.children().html('eng');
  }

  rus() {
    this.$english.show();
    this.$russian.hide();
    this.$changes.hide();
    this.$node.children().html('рус');
  }
}

import { chain } from 'chain-decorator';
import { bind } from 'decko';

export default class GlobalHandler {
  events = []
  keyCodes = {}

  @chain
  esc(handler) {
    this.keyup(27, handler);
  }

  @chain
  slash(handler) {
    this.keyup(47, handler);
    this.keyup(191, handler);
  }

  @chain
  up(handler) {
    this.keydown(38, handler);
  }

  @chain
  down(handler) {
    this.keydown(40, handler);
  }

  keyup(keyCode, handler) {
    this._bind('keyup');
    this.keyCodes[keyCode] = handler;
  }

  keydown(keyCode, handler) {
    this._bind('keydown');
    this.keyCodes[keyCode] = handler;
  }

  @bind
  _onKeyup(e) {
    Object.forEach(this.keyCodes, (handler, keyCode) => {
      if (e.keyCode.toString() === keyCode) {
        handler(e);
      }
    });
  }

  @bind
  _onKeydown(e) {
    Object.forEach(this.keyCodes, (handler, keyCode) => {
      if (e.keyCode.toString() === keyCode) {
        handler(e);
      }
    });
  }

  @bind
  _unbindAll() {
    this.events.forEach(event => {
      if (event === 'focus') {
        $(document).off(event, '*', this._handler(event));
      } else {
        $(document).off(event, this._handler(event));
      }
    });

    this.events = [];
    this.keyCodes = {};
  }

  _handler(event) {
    return this[`_on${event.capitalize()}`];
  }

  _bind(event) {
    if (this.events.includes(event)) { return; }

    $(document).on(event, this._handler(event));

    if (Object.isEmpty(this.events)) {
      this._scheduleUnbind();
    }
    this.events.push(event);
  }

  _scheduleUnbind() {
    $(document).one('turbolinks:before-cache', this._unbindAll);
  }
}

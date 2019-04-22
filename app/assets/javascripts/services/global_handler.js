import { chain } from 'chain-decorator';
import { bind } from 'decko';

const KEY_CODES = {
  esc: 27,
  slash: [47, 191],
  up: 38,
  down: 40
};
const KEYDOWN_CODES = [38, 40];

function keyCodeEvent(keyCode) {
  return KEYDOWN_CODES.includes(keyCode) ? 'keydown' : 'keyup';
}

export default class GlobalHandler {
  events = {}

  @chain
  on(key, handler) {
    if (key.constructor === String) {
      if (KEY_CODES[key].constructor === Array) {
        KEY_CODES[key].forEach(keyCode => this._bind(null, keyCode, handler));
      } else {
        this._bind(null, KEY_CODES[key], handler);
      }
    } else {
      this._bind(null, key, handler);
    }
  }

  @chain
  off(key, handler) {
    if (key.constructor === String) {
      if (KEY_CODES[key].constructor === Array) {
        KEY_CODES[key].forEach(keyCode => this._unbind(null, keyCode, handler));
      } else {
        this._unbind(null, KEY_CODES[key], handler);
      }
    } else {
      this._unbind(null, key, handler);
    }
  }

  @bind
  _onKeyup(e) {
    const handlers = this.events.keyup[e.keyCode];
    if (!handlers) { return; }

    handlers.forEach(handler => handler(e));
  }

  @bind
  _onKeydown(e) {
    const handlers = this.events.keydown[e.keyCode];
    if (!handlers) { return; }

    handlers.forEach(handler => handler(e));
  }

  _bind(event, keyCode, handler) {
    if (!event) { event = keyCodeEvent(keyCode); } // eslint-disable-line no-param-reassign

    if (!this.events[event]) {
      $(document).on(event, this._handler(event));

      if (Object.isEmpty(this.events)) {
        this._scheduleUnbind();
      }
      this.events[event] = {};
    }

    if (!this.events[event][keyCode]) {
      this.events[event][keyCode] = [];
    }
    this.events[event][keyCode].push(handler);
  }

  _unbind(event, keyCode, handler) {
    if (!event) { event = keyCodeEvent(keyCode); } // eslint-disable-line no-param-reassign
    if (!this.events[event]) { return; }
    if (!this.events[event][keyCode]) { return; }
    if (!this.events[event][keyCode].includes(handler)) { return; }

    this.events[event][keyCode].splice(
      this.events[event][keyCode].indexOf(handler),
      1
    );
    if (Object.isEmpty(this.events[event][keyCode])) {
      delete this.events[event][keyCode];
    }
    if (Object.isEmpty(this.events[event])) {
      this._unbindEvent(event);
      delete this.events[event];
    }
    if (Object.isEmpty(this.event)) {
      this._unScheduleUnbind();
    }
  }

  @bind
  _unbindAll() {
    Object.keys(this.events).forEach(event => this._unbindEvent(event));
    this.events = {};
  }

  _unbindEvent(event) {
    if (event === 'focus') {
      $(document).off(event, '*', this._handler(event));
    } else {
      $(document).off(event, this._handler(event));
    }
  }

  _handler(event) {
    return this[`_on${event.capitalize()}`];
  }

  _scheduleUnbind() {
    $(document).one('turbolinks:before-cache', this._unbindAll);
  }

  _unScheduleUnbind() {
    $(document).off('turbolinks:before-cache', this._unbindAll);
  }
}

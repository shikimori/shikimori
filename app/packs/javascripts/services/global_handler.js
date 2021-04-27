import { chain, bind } from 'shiki-decorators';

const KEY_CODES = {
  enter: 13,
  esc: 27,
  slash: [47, 191],
  up: 38,
  down: 40
};
const KEYDOWN_CODES = [38, 40, 47, 191];

function keyCodeEvent(keyCode) {
  return KEYDOWN_CODES.includes(keyCode) ? 'keydown' : 'keyup';
}

export default class GlobalHandler {
  events = {}

  @chain
  on(key, handler) {
    if (key === 'focus') {
      this._bind('focus', null, handler);
    } else if (key.constructor === String) {
      // key name
      if (KEY_CODES[key].constructor === Array) {
        KEY_CODES[key].forEach(keyCode => this._bind(null, keyCode, handler));
      } else {
        this._bind(null, KEY_CODES[key], handler);
      }
    } else {
      // key code
      this._bind(null, key, handler);
    }
  }

  @chain
  off(key, handler) {
    if (key === 'focus') {
      this._unbind('focus', null, handler);
    } else if (key.constructor === String) {
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
    if (!this.events.keyup || !this.events.keyup[e.keyCode]) { return; }

    this.events.keyup[e.keyCode].forEach(handler => handler(e));
  }

  @bind
  _onKeydown(e) {
    if (!this.events.keydown || !this.events.keydown[e.keyCode]) { return; }

    this.events.keydown[e.keyCode].forEach(handler => handler(e));
  }

  @bind
  _onFocus(e) {
    if (!this.events.focus || !this.events.focus.null) { return; }

    this.events.focus.null.forEach(handler => handler(e));
  }

  _bind(event, keyCode, handler) {
    if (!event) { event = keyCodeEvent(keyCode); } // eslint-disable-line no-param-reassign

    if (!this.events[event]) {
      if (event === 'focus') {
        $(document.body).on(event, '*', this._handler(event));
      } else {
        $(document).on(event, this._handler(event));
      }

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
    if (Object.isEmpty(this.events)) {
      this._unScheduleUnbind();
    }
  }

  @bind
  _unbindAll() {
    Object.keys(this.events).forEach(event => this._unbindEvent(event));
    this._unScheduleUnbind();
    this.events = {};
  }

  _unbindEvent(event) {
    if (event === 'focus') {
      $(document.body).off(event, '*', this._handler(event));
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

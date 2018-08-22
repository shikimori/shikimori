$.fn.extend({
  triggerWithReturn(name, data) {
    const event = new $.Event(name);
    this.trigger(event, data);
    return event.result;
  }
});

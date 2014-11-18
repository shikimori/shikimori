jQuery(function ($) {
  $.fn.extend({
    /**
      * Triggers a custom event on an element and returns the event result
      * this is used to get around not being able to ensure callbacks are placed
      * at the end of the chain.
      *
      */
    trigger_with_return: function (name, data) {
        var event = new $.Event(name);
        this.trigger(event, data);

        return event.result;
    }
  });
})

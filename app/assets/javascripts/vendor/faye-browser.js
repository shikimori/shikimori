var Faye =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var constants = __webpack_require__(1),
	    Logging   = __webpack_require__(2);
	
	var Faye = {
	  VERSION:    constants.VERSION,
	
	  Client:     __webpack_require__(4),
	  Scheduler:  __webpack_require__(32)
	};
	
	Logging.wrapper = Faye;
	
	module.exports = Faye;


/***/ },
/* 1 */
/***/ function(module, exports) {

	module.exports = {
	  VERSION:          '1.2.3',
	
	  BAYEUX_VERSION:   '1.0',
	  ID_LENGTH:        160,
	  JSONP_CALLBACK:   'jsonpcallback',
	  CONNECTION_TYPES: ['long-polling', 'cross-origin-long-polling', 'callback-polling', 'websocket', 'eventsource', 'in-process'],
	
	  MANDATORY_CONNECTION_TYPES: ['long-polling', 'callback-polling', 'in-process']
	};


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var toJSON = __webpack_require__(3);
	
	var Logging = {
	  LOG_LEVELS: {
	    fatal:  4,
	    error:  3,
	    warn:   2,
	    info:   1,
	    debug:  0
	  },
	
	  writeLog: function(messageArgs, level) {
	    var logger = Logging.logger || (Logging.wrapper || Logging).logger;
	    if (!logger) return;
	
	    var args   = Array.prototype.slice.apply(messageArgs),
	        banner = '[Faye',
	        klass  = this.className,
	
	        message = args.shift().replace(/\?/g, function() {
	          try {
	            return toJSON(args.shift());
	          } catch (error) {
	            return '[Object]';
	          }
	        });
	
	    if (klass) banner += '.' + klass;
	    banner += '] ';
	
	    if (typeof logger[level] === 'function')
	      logger[level](banner + message);
	    else if (typeof logger === 'function')
	      logger(banner + message);
	  }
	};
	
	for (var key in Logging.LOG_LEVELS)
	  (function(level) {
	    Logging[level] = function() {
	      this.writeLog(arguments, level);
	    };
	  })(key);
	
	module.exports = Logging;


/***/ },
/* 3 */
/***/ function(module, exports) {

	'use strict';
	
	// http://assanka.net/content/tech/2009/09/02/json2-js-vs-prototype/
	
	module.exports = function(object) {
	  return JSON.stringify(object, function(key, value) {
	    return (this[key] instanceof Array) ? this[key] : value;
	  });
	};


/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var asap            = __webpack_require__(5),
	    Class           = __webpack_require__(7),
	    Promise         = __webpack_require__(9),
	    URI             = __webpack_require__(10),
	    array           = __webpack_require__(11),
	    browser         = __webpack_require__(12),
	    constants       = __webpack_require__(1),
	    extend          = __webpack_require__(8),
	    validateOptions = __webpack_require__(13),
	    Deferrable      = __webpack_require__(14),
	    Logging         = __webpack_require__(2),
	    Publisher       = __webpack_require__(15),
	    Channel         = __webpack_require__(17),
	    Dispatcher      = __webpack_require__(19),
	    Error           = __webpack_require__(33),
	    Extensible      = __webpack_require__(34),
	    Publication     = __webpack_require__(35),
	    Subscription    = __webpack_require__(36);
	
	var Client = Class({ className: 'Client',
	  UNCONNECTED:        1,
	  CONNECTING:         2,
	  CONNECTED:          3,
	  DISCONNECTED:       4,
	
	  HANDSHAKE:          'handshake',
	  RETRY:              'retry',
	  NONE:               'none',
	
	  CONNECTION_TIMEOUT: 60,
	
	  DEFAULT_ENDPOINT:   '/bayeux',
	  INTERVAL:           0,
	
	  initialize: function(endpoint, options) {
	    this.info('New client created for ?', endpoint);
	    options = options || {};
	
	    validateOptions(options, ['interval', 'timeout', 'endpoints', 'proxy', 'retry', 'scheduler', 'websocketExtensions', 'tls', 'ca']);
	
	    this._channels   = new Channel.Set();
	    this._dispatcher = Dispatcher.create(this, endpoint || this.DEFAULT_ENDPOINT, options);
	
	    this._messageId = 0;
	    this._state     = this.UNCONNECTED;
	
	    this._responseCallbacks = {};
	
	    this._advice = {
	      reconnect: this.RETRY,
	      interval:  1000 * (options.interval || this.INTERVAL),
	      timeout:   1000 * (options.timeout  || this.CONNECTION_TIMEOUT)
	    };
	    this._dispatcher.timeout = this._advice.timeout / 1000;
	
	    this._dispatcher.bind('message', this._receiveMessage, this);
	
	    if (browser.Event && global.onbeforeunload !== undefined)
	      browser.Event.on(global, 'beforeunload', function() {
	        if (array.indexOf(this._dispatcher._disabled, 'autodisconnect') < 0)
	          this.disconnect();
	      }, this);
	  },
	
	  addWebsocketExtension: function(extension) {
	    return this._dispatcher.addWebsocketExtension(extension);
	  },
	
	  disable: function(feature) {
	    return this._dispatcher.disable(feature);
	  },
	
	  setHeader: function(name, value) {
	    return this._dispatcher.setHeader(name, value);
	  },
	
	  // Request
	  // MUST include:  * channel
	  //                * version
	  //                * supportedConnectionTypes
	  // MAY include:   * minimumVersion
	  //                * ext
	  //                * id
	  //
	  // Success Response                             Failed Response
	  // MUST include:  * channel                     MUST include:  * channel
	  //                * version                                    * successful
	  //                * supportedConnectionTypes                   * error
	  //                * clientId                    MAY include:   * supportedConnectionTypes
	  //                * successful                                 * advice
	  // MAY include:   * minimumVersion                             * version
	  //                * advice                                     * minimumVersion
	  //                * ext                                        * ext
	  //                * id                                         * id
	  //                * authSuccessful
	  handshake: function(callback, context) {
	    if (this._advice.reconnect === this.NONE) return;
	    if (this._state !== this.UNCONNECTED) return;
	
	    this._state = this.CONNECTING;
	    var self = this;
	
	    this.info('Initiating handshake with ?', URI.stringify(this._dispatcher.endpoint));
	    this._dispatcher.selectTransport(constants.MANDATORY_CONNECTION_TYPES);
	
	    this._sendMessage({
	      channel:                  Channel.HANDSHAKE,
	      version:                  constants.BAYEUX_VERSION,
	      supportedConnectionTypes: this._dispatcher.getConnectionTypes()
	
	    }, {}, function(response) {
	
	      if (response.successful) {
	        this._state = this.CONNECTED;
	        this._dispatcher.clientId  = response.clientId;
	
	        this._dispatcher.selectTransport(response.supportedConnectionTypes);
	
	        this.info('Handshake successful: ?', this._dispatcher.clientId);
	
	        this.subscribe(this._channels.getKeys(), true);
	        if (callback) asap(function() { callback.call(context) });
	
	      } else {
	        this.info('Handshake unsuccessful');
	        global.setTimeout(function() { self.handshake(callback, context) }, this._dispatcher.retry * 1000);
	        this._state = this.UNCONNECTED;
	      }
	    }, this);
	  },
	
	  // Request                              Response
	  // MUST include:  * channel             MUST include:  * channel
	  //                * clientId                           * successful
	  //                * connectionType                     * clientId
	  // MAY include:   * ext                 MAY include:   * error
	  //                * id                                 * advice
	  //                                                     * ext
	  //                                                     * id
	  //                                                     * timestamp
	  connect: function(callback, context) {
	    if (this._advice.reconnect === this.NONE) return;
	    if (this._state === this.DISCONNECTED) return;
	
	    if (this._state === this.UNCONNECTED)
	      return this.handshake(function() { this.connect(callback, context) }, this);
	
	    this.callback(callback, context);
	    if (this._state !== this.CONNECTED) return;
	
	    this.info('Calling deferred actions for ?', this._dispatcher.clientId);
	    this.setDeferredStatus('succeeded');
	    this.setDeferredStatus('unknown');
	
	    if (this._connectRequest) return;
	    this._connectRequest = true;
	
	    this.info('Initiating connection for ?', this._dispatcher.clientId);
	
	    this._sendMessage({
	      channel:        Channel.CONNECT,
	      clientId:       this._dispatcher.clientId,
	      connectionType: this._dispatcher.connectionType
	
	    }, {}, this._cycleConnection, this);
	  },
	
	  // Request                              Response
	  // MUST include:  * channel             MUST include:  * channel
	  //                * clientId                           * successful
	  // MAY include:   * ext                                * clientId
	  //                * id                  MAY include:   * error
	  //                                                     * ext
	  //                                                     * id
	  disconnect: function() {
	    if (this._state !== this.CONNECTED) return;
	    this._state = this.DISCONNECTED;
	
	    this.info('Disconnecting ?', this._dispatcher.clientId);
	    var promise = new Publication();
	
	    this._sendMessage({
	      channel:  Channel.DISCONNECT,
	      clientId: this._dispatcher.clientId
	
	    }, {}, function(response) {
	      if (response.successful) {
	        this._dispatcher.close();
	        promise.setDeferredStatus('succeeded');
	      } else {
	        promise.setDeferredStatus('failed', Error.parse(response.error));
	      }
	    }, this);
	
	    this.info('Clearing channel listeners for ?', this._dispatcher.clientId);
	    this._channels = new Channel.Set();
	
	    return promise;
	  },
	
	  // Request                              Response
	  // MUST include:  * channel             MUST include:  * channel
	  //                * clientId                           * successful
	  //                * subscription                       * clientId
	  // MAY include:   * ext                                * subscription
	  //                * id                  MAY include:   * error
	  //                                                     * advice
	  //                                                     * ext
	  //                                                     * id
	  //                                                     * timestamp
	  subscribe: function(channel, callback, context) {
	    if (channel instanceof Array)
	      return array.map(channel, function(c) {
	        return this.subscribe(c, callback, context);
	      }, this);
	
	    var subscription = new Subscription(this, channel, callback, context),
	        force        = (callback === true),
	        hasSubscribe = this._channels.hasSubscription(channel);
	
	    if (hasSubscribe && !force) {
	      this._channels.subscribe([channel], subscription);
	      subscription.setDeferredStatus('succeeded');
	      return subscription;
	    }
	
	    this.connect(function() {
	      this.info('Client ? attempting to subscribe to ?', this._dispatcher.clientId, channel);
	      if (!force) this._channels.subscribe([channel], subscription);
	
	      this._sendMessage({
	        channel:      Channel.SUBSCRIBE,
	        clientId:     this._dispatcher.clientId,
	        subscription: channel
	
	      }, {}, function(response) {
	        if (!response.successful) {
	          subscription.setDeferredStatus('failed', Error.parse(response.error));
	          return this._channels.unsubscribe(channel, subscription);
	        }
	
	        var channels = [].concat(response.subscription);
	        this.info('Subscription acknowledged for ? to ?', this._dispatcher.clientId, channels);
	        subscription.setDeferredStatus('succeeded');
	      }, this);
	    }, this);
	
	    return subscription;
	  },
	
	  // Request                              Response
	  // MUST include:  * channel             MUST include:  * channel
	  //                * clientId                           * successful
	  //                * subscription                       * clientId
	  // MAY include:   * ext                                * subscription
	  //                * id                  MAY include:   * error
	  //                                                     * advice
	  //                                                     * ext
	  //                                                     * id
	  //                                                     * timestamp
	  unsubscribe: function(channel, subscription) {
	    if (channel instanceof Array)
	      return array.map(channel, function(c) {
	        return this.unsubscribe(c, subscription);
	      }, this);
	
	    var dead = this._channels.unsubscribe(channel, subscription);
	    if (!dead) return;
	
	    this.connect(function() {
	      this.info('Client ? attempting to unsubscribe from ?', this._dispatcher.clientId, channel);
	
	      this._sendMessage({
	        channel:      Channel.UNSUBSCRIBE,
	        clientId:     this._dispatcher.clientId,
	        subscription: channel
	
	      }, {}, function(response) {
	        if (!response.successful) return;
	
	        var channels = [].concat(response.subscription);
	        this.info('Unsubscription acknowledged for ? from ?', this._dispatcher.clientId, channels);
	      }, this);
	    }, this);
	  },
	
	  // Request                              Response
	  // MUST include:  * channel             MUST include:  * channel
	  //                * data                               * successful
	  // MAY include:   * clientId            MAY include:   * id
	  //                * id                                 * error
	  //                * ext                                * ext
	  publish: function(channel, data, options) {
	    validateOptions(options || {}, ['attempts', 'deadline']);
	    var publication = new Publication();
	
	    this.connect(function() {
	      this.info('Client ? queueing published message to ?: ?', this._dispatcher.clientId, channel, data);
	
	      this._sendMessage({
	        channel:  channel,
	        data:     data,
	        clientId: this._dispatcher.clientId
	
	      }, options, function(response) {
	        if (response.successful)
	          publication.setDeferredStatus('succeeded');
	        else
	          publication.setDeferredStatus('failed', Error.parse(response.error));
	      }, this);
	    }, this);
	
	    return publication;
	  },
	
	  _sendMessage: function(message, options, callback, context) {
	    message.id = this._generateMessageId();
	
	    var timeout = this._advice.timeout
	                ? 1.2 * this._advice.timeout / 1000
	                : 1.2 * this._dispatcher.retry;
	
	    this.pipeThroughExtensions('outgoing', message, null, function(message) {
	      if (!message) return;
	      if (callback) this._responseCallbacks[message.id] = [callback, context];
	      this._dispatcher.sendMessage(message, timeout, options || {});
	    }, this);
	  },
	
	  _generateMessageId: function() {
	    this._messageId += 1;
	    if (this._messageId >= Math.pow(2,32)) this._messageId = 0;
	    return this._messageId.toString(36);
	  },
	
	  _receiveMessage: function(message) {
	    var id = message.id, callback;
	
	    if (message.successful !== undefined) {
	      callback = this._responseCallbacks[id];
	      delete this._responseCallbacks[id];
	    }
	
	    this.pipeThroughExtensions('incoming', message, null, function(message) {
	      if (!message) return;
	      if (message.advice) this._handleAdvice(message.advice);
	      this._deliverMessage(message);
	      if (callback) callback[0].call(callback[1], message);
	    }, this);
	  },
	
	  _handleAdvice: function(advice) {
	    extend(this._advice, advice);
	    this._dispatcher.timeout = this._advice.timeout / 1000;
	
	    if (this._advice.reconnect === this.HANDSHAKE && this._state !== this.DISCONNECTED) {
	      this._state = this.UNCONNECTED;
	      this._dispatcher.clientId = null;
	      this._cycleConnection();
	    }
	  },
	
	  _deliverMessage: function(message) {
	    if (!message.channel || message.data === undefined) return;
	    this.info('Client ? calling listeners for ? with ?', this._dispatcher.clientId, message.channel, message.data);
	    this._channels.distributeMessage(message);
	  },
	
	  _cycleConnection: function() {
	    if (this._connectRequest) {
	      this._connectRequest = null;
	      this.info('Closed connection for ?', this._dispatcher.clientId);
	    }
	    var self = this;
	    global.setTimeout(function() { self.connect() }, this._advice.interval);
	  }
	});
	
	extend(Client.prototype, Deferrable);
	extend(Client.prototype, Publisher);
	extend(Client.prototype, Logging);
	extend(Client.prototype, Extensible);
	
	module.exports = Client;
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	"use strict";
	
	// rawAsap provides everything we need except exception management.
	var rawAsap = __webpack_require__(6);
	// RawTasks are recycled to reduce GC churn.
	var freeTasks = [];
	// We queue errors to ensure they are thrown in right order (FIFO).
	// Array-as-queue is good enough here, since we are just dealing with exceptions.
	var pendingErrors = [];
	var requestErrorThrow = rawAsap.makeRequestCallFromTimer(throwFirstError);
	
	function throwFirstError() {
	    if (pendingErrors.length) {
	        throw pendingErrors.shift();
	    }
	}
	
	/**
	 * Calls a task as soon as possible after returning, in its own event, with priority
	 * over other events like animation, reflow, and repaint. An error thrown from an
	 * event will not interrupt, nor even substantially slow down the processing of
	 * other events, but will be rather postponed to a lower priority event.
	 * @param {{call}} task A callable object, typically a function that takes no
	 * arguments.
	 */
	module.exports = asap;
	function asap(task) {
	    var rawTask;
	    if (freeTasks.length) {
	        rawTask = freeTasks.pop();
	    } else {
	        rawTask = new RawTask();
	    }
	    rawTask.task = task;
	    rawAsap(rawTask);
	}
	
	// We wrap tasks with recyclable task objects.  A task object implements
	// `call`, just like a function.
	function RawTask() {
	    this.task = null;
	}
	
	// The sole purpose of wrapping the task is to catch the exception and recycle
	// the task object after its single use.
	RawTask.prototype.call = function () {
	    try {
	        this.task.call();
	    } catch (error) {
	        if (asap.onerror) {
	            // This hook exists purely for testing purposes.
	            // Its name will be periodically randomized to break any code that
	            // depends on its existence.
	            asap.onerror(error);
	        } else {
	            // In a web browser, exceptions are not fatal. However, to avoid
	            // slowing down the queue of pending tasks, we rethrow the error in a
	            // lower priority turn.
	            pendingErrors.push(error);
	            requestErrorThrow();
	        }
	    } finally {
	        this.task = null;
	        freeTasks[freeTasks.length] = this;
	    }
	};


/***/ },
/* 6 */
/***/ function(module, exports) {

	/* WEBPACK VAR INJECTION */(function(global) {"use strict";
	
	// Use the fastest means possible to execute a task in its own turn, with
	// priority over other events including IO, animation, reflow, and redraw
	// events in browsers.
	//
	// An exception thrown by a task will permanently interrupt the processing of
	// subsequent tasks. The higher level `asap` function ensures that if an
	// exception is thrown by a task, that the task queue will continue flushing as
	// soon as possible, but if you use `rawAsap` directly, you are responsible to
	// either ensure that no exceptions are thrown from your task, or to manually
	// call `rawAsap.requestFlush` if an exception is thrown.
	module.exports = rawAsap;
	function rawAsap(task) {
	    if (!queue.length) {
	        requestFlush();
	        flushing = true;
	    }
	    // Equivalent to push, but avoids a function call.
	    queue[queue.length] = task;
	}
	
	var queue = [];
	// Once a flush has been requested, no further calls to `requestFlush` are
	// necessary until the next `flush` completes.
	var flushing = false;
	// `requestFlush` is an implementation-specific method that attempts to kick
	// off a `flush` event as quickly as possible. `flush` will attempt to exhaust
	// the event queue before yielding to the browser's own event loop.
	var requestFlush;
	// The position of the next task to execute in the task queue. This is
	// preserved between calls to `flush` so that it can be resumed if
	// a task throws an exception.
	var index = 0;
	// If a task schedules additional tasks recursively, the task queue can grow
	// unbounded. To prevent memory exhaustion, the task queue will periodically
	// truncate already-completed tasks.
	var capacity = 1024;
	
	// The flush function processes all tasks that have been scheduled with
	// `rawAsap` unless and until one of those tasks throws an exception.
	// If a task throws an exception, `flush` ensures that its state will remain
	// consistent and will resume where it left off when called again.
	// However, `flush` does not make any arrangements to be called again if an
	// exception is thrown.
	function flush() {
	    while (index < queue.length) {
	        var currentIndex = index;
	        // Advance the index before calling the task. This ensures that we will
	        // begin flushing on the next task the task throws an error.
	        index = index + 1;
	        queue[currentIndex].call();
	        // Prevent leaking memory for long chains of recursive calls to `asap`.
	        // If we call `asap` within tasks scheduled by `asap`, the queue will
	        // grow, but to avoid an O(n) walk for every task we execute, we don't
	        // shift tasks off the queue after they have been executed.
	        // Instead, we periodically shift 1024 tasks off the queue.
	        if (index > capacity) {
	            // Manually shift all values starting at the index back to the
	            // beginning of the queue.
	            for (var scan = 0, newLength = queue.length - index; scan < newLength; scan++) {
	                queue[scan] = queue[scan + index];
	            }
	            queue.length -= index;
	            index = 0;
	        }
	    }
	    queue.length = 0;
	    index = 0;
	    flushing = false;
	}
	
	// `requestFlush` is implemented using a strategy based on data collected from
	// every available SauceLabs Selenium web driver worker at time of writing.
	// https://docs.google.com/spreadsheets/d/1mG-5UYGup5qxGdEMWkhP6BWCz053NUb2E1QoUTU16uA/edit#gid=783724593
	
	// Safari 6 and 6.1 for desktop, iPad, and iPhone are the only browsers that
	// have WebKitMutationObserver but not un-prefixed MutationObserver.
	// Must use `global` or `self` instead of `window` to work in both frames and web
	// workers. `global` is a provision of Browserify, Mr, Mrs, or Mop.
	
	/* globals self */
	var scope = typeof global !== "undefined" ? global : self;
	var BrowserMutationObserver = scope.MutationObserver || scope.WebKitMutationObserver;
	
	// MutationObservers are desirable because they have high priority and work
	// reliably everywhere they are implemented.
	// They are implemented in all modern browsers.
	//
	// - Android 4-4.3
	// - Chrome 26-34
	// - Firefox 14-29
	// - Internet Explorer 11
	// - iPad Safari 6-7.1
	// - iPhone Safari 7-7.1
	// - Safari 6-7
	if (typeof BrowserMutationObserver === "function") {
	    requestFlush = makeRequestCallFromMutationObserver(flush);
	
	// MessageChannels are desirable because they give direct access to the HTML
	// task queue, are implemented in Internet Explorer 10, Safari 5.0-1, and Opera
	// 11-12, and in web workers in many engines.
	// Although message channels yield to any queued rendering and IO tasks, they
	// would be better than imposing the 4ms delay of timers.
	// However, they do not work reliably in Internet Explorer or Safari.
	
	// Internet Explorer 10 is the only browser that has setImmediate but does
	// not have MutationObservers.
	// Although setImmediate yields to the browser's renderer, it would be
	// preferrable to falling back to setTimeout since it does not have
	// the minimum 4ms penalty.
	// Unfortunately there appears to be a bug in Internet Explorer 10 Mobile (and
	// Desktop to a lesser extent) that renders both setImmediate and
	// MessageChannel useless for the purposes of ASAP.
	// https://github.com/kriskowal/q/issues/396
	
	// Timers are implemented universally.
	// We fall back to timers in workers in most engines, and in foreground
	// contexts in the following browsers.
	// However, note that even this simple case requires nuances to operate in a
	// broad spectrum of browsers.
	//
	// - Firefox 3-13
	// - Internet Explorer 6-9
	// - iPad Safari 4.3
	// - Lynx 2.8.7
	} else {
	    requestFlush = makeRequestCallFromTimer(flush);
	}
	
	// `requestFlush` requests that the high priority event queue be flushed as
	// soon as possible.
	// This is useful to prevent an error thrown in a task from stalling the event
	// queue if the exception handled by Node.js’s
	// `process.on("uncaughtException")` or by a domain.
	rawAsap.requestFlush = requestFlush;
	
	// To request a high priority event, we induce a mutation observer by toggling
	// the text of a text node between "1" and "-1".
	function makeRequestCallFromMutationObserver(callback) {
	    var toggle = 1;
	    var observer = new BrowserMutationObserver(callback);
	    var node = document.createTextNode("");
	    observer.observe(node, {characterData: true});
	    return function requestCall() {
	        toggle = -toggle;
	        node.data = toggle;
	    };
	}
	
	// The message channel technique was discovered by Malte Ubl and was the
	// original foundation for this library.
	// http://www.nonblocking.io/2011/06/windownexttick.html
	
	// Safari 6.0.5 (at least) intermittently fails to create message ports on a
	// page's first load. Thankfully, this version of Safari supports
	// MutationObservers, so we don't need to fall back in that case.
	
	// function makeRequestCallFromMessageChannel(callback) {
	//     var channel = new MessageChannel();
	//     channel.port1.onmessage = callback;
	//     return function requestCall() {
	//         channel.port2.postMessage(0);
	//     };
	// }
	
	// For reasons explained above, we are also unable to use `setImmediate`
	// under any circumstances.
	// Even if we were, there is another bug in Internet Explorer 10.
	// It is not sufficient to assign `setImmediate` to `requestFlush` because
	// `setImmediate` must be called *by name* and therefore must be wrapped in a
	// closure.
	// Never forget.
	
	// function makeRequestCallFromSetImmediate(callback) {
	//     return function requestCall() {
	//         setImmediate(callback);
	//     };
	// }
	
	// Safari 6.0 has a problem where timers will get lost while the user is
	// scrolling. This problem does not impact ASAP because Safari 6.0 supports
	// mutation observers, so that implementation is used instead.
	// However, if we ever elect to use timers in Safari, the prevalent work-around
	// is to add a scroll event listener that calls for a flush.
	
	// `setTimeout` does not call the passed callback if the delay is less than
	// approximately 7 in web workers in Firefox 8 through 18, and sometimes not
	// even then.
	
	function makeRequestCallFromTimer(callback) {
	    return function requestCall() {
	        // We dispatch a timeout with a specified delay of 0 for engines that
	        // can reliably accommodate that request. This will usually be snapped
	        // to a 4 milisecond delay, but once we're flushing, there's no delay
	        // between events.
	        var timeoutHandle = setTimeout(handleTimer, 0);
	        // However, since this timer gets frequently dropped in Firefox
	        // workers, we enlist an interval handle that will try to fire
	        // an event 20 times per second until it succeeds.
	        var intervalHandle = setInterval(handleTimer, 50);
	
	        function handleTimer() {
	            // Whichever timer succeeds will cancel both timers and
	            // execute the callback.
	            clearTimeout(timeoutHandle);
	            clearInterval(intervalHandle);
	            callback();
	        }
	    };
	}
	
	// This is for `asap.js` only.
	// Its name will be periodically randomized to break any code that depends on
	// its existence.
	rawAsap.makeRequestCallFromTimer = makeRequestCallFromTimer;
	
	// ASAP was originally a nextTick shim included in Q. This was factored out
	// into this ASAP package. It was later adapted to RSVP which made further
	// amendments. These decisions, particularly to marginalize MessageChannel and
	// to capture the MutationObserver implementation in a closure, were integrated
	// back into ASAP proper.
	// https://github.com/tildeio/rsvp.js/blob/cddf7232546a9cf858524b75cde6f9edf72620a7/lib/rsvp/asap.js
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var extend = __webpack_require__(8);
	
	module.exports = function(parent, methods) {
	  if (typeof parent !== 'function') {
	    methods = parent;
	    parent  = Object;
	  }
	
	  var klass = function() {
	    if (!this.initialize) return this;
	    return this.initialize.apply(this, arguments) || this;
	  };
	
	  var bridge = function() {};
	  bridge.prototype = parent.prototype;
	
	  klass.prototype = new bridge();
	  extend(klass.prototype, methods);
	
	  return klass;
	};


/***/ },
/* 8 */
/***/ function(module, exports) {

	'use strict';
	
	module.exports = function(dest, source, overwrite) {
	  if (!source) return dest;
	  for (var key in source) {
	    if (!source.hasOwnProperty(key)) continue;
	    if (dest.hasOwnProperty(key) && overwrite === false) continue;
	    if (dest[key] !== source[key])
	      dest[key] = source[key];
	  }
	  return dest;
	};


/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var asap = __webpack_require__(5);
	
	var PENDING   = 0,
	    FULFILLED = 1,
	    REJECTED  = 2;
	
	var RETURN = function(x) { return x },
	    THROW  = function(x) { throw  x };
	
	var Promise = function(task) {
	  this._state       = PENDING;
	  this._onFulfilled = [];
	  this._onRejected  = [];
	
	  if (typeof task !== 'function') return;
	  var self = this;
	
	  task(function(value)  { resolve(self, value) },
	       function(reason) { reject(self, reason) });
	};
	
	Promise.prototype.then = function(onFulfilled, onRejected) {
	  var next = new Promise();
	  registerOnFulfilled(this, onFulfilled, next);
	  registerOnRejected(this, onRejected, next);
	  return next;
	};
	
	Promise.prototype.catch = function(onRejected) {
	  return this.then(null, onRejected);
	};
	
	var registerOnFulfilled = function(promise, onFulfilled, next) {
	  if (typeof onFulfilled !== 'function') onFulfilled = RETURN;
	  var handler = function(value) { invoke(onFulfilled, value, next) };
	
	  if (promise._state === PENDING) {
	    promise._onFulfilled.push(handler);
	  } else if (promise._state === FULFILLED) {
	    handler(promise._value);
	  }
	};
	
	var registerOnRejected = function(promise, onRejected, next) {
	  if (typeof onRejected !== 'function') onRejected = THROW;
	  var handler = function(reason) { invoke(onRejected, reason, next) };
	
	  if (promise._state === PENDING) {
	    promise._onRejected.push(handler);
	  } else if (promise._state === REJECTED) {
	    handler(promise._reason);
	  }
	};
	
	var invoke = function(fn, value, next) {
	  asap(function() { _invoke(fn, value, next) });
	};
	
	var _invoke = function(fn, value, next) {
	  var outcome;
	
	  try {
	    outcome = fn(value);
	  } catch (error) {
	    return reject(next, error);
	  }
	
	  if (outcome === next) {
	    reject(next, new TypeError('Recursive promise chain detected'));
	  } else {
	    resolve(next, outcome);
	  }
	};
	
	var resolve = function(promise, value) {
	  var called = false, type, then;
	
	  try {
	    type = typeof value;
	    then = value !== null && (type === 'function' || type === 'object') && value.then;
	
	    if (typeof then !== 'function') return fulfill(promise, value);
	
	    then.call(value, function(v) {
	      if (!(called ^ (called = true))) return;
	      resolve(promise, v);
	    }, function(r) {
	      if (!(called ^ (called = true))) return;
	      reject(promise, r);
	    });
	  } catch (error) {
	    if (!(called ^ (called = true))) return;
	    reject(promise, error);
	  }
	};
	
	var fulfill = function(promise, value) {
	  if (promise._state !== PENDING) return;
	
	  promise._state      = FULFILLED;
	  promise._value      = value;
	  promise._onRejected = [];
	
	  var onFulfilled = promise._onFulfilled, fn;
	  while (fn = onFulfilled.shift()) fn(value);
	};
	
	var reject = function(promise, reason) {
	  if (promise._state !== PENDING) return;
	
	  promise._state       = REJECTED;
	  promise._reason      = reason;
	  promise._onFulfilled = [];
	
	  var onRejected = promise._onRejected, fn;
	  while (fn = onRejected.shift()) fn(reason);
	};
	
	Promise.resolve = function(value) {
	  return new Promise(function(resolve, reject) { resolve(value) });
	};
	
	Promise.reject = function(reason) {
	  return new Promise(function(resolve, reject) { reject(reason) });
	};
	
	Promise.all = function(promises) {
	  return new Promise(function(resolve, reject) {
	    var list = [], n = promises.length, i;
	
	    if (n === 0) return resolve(list);
	
	    for (i = 0; i < n; i++) (function(promise, i) {
	      Promise.resolve(promise).then(function(value) {
	        list[i] = value;
	        if (--n === 0) resolve(list);
	      }, reject);
	    })(promises[i], i);
	  });
	};
	
	Promise.race = function(promises) {
	  return new Promise(function(resolve, reject) {
	    for (var i = 0, n = promises.length; i < n; i++)
	      Promise.resolve(promises[i]).then(resolve, reject);
	  });
	};
	
	Promise.deferred = Promise.pending = function() {
	  var tuple = {};
	
	  tuple.promise = new Promise(function(resolve, reject) {
	    tuple.resolve = resolve;
	    tuple.reject  = reject;
	  });
	  return tuple;
	};
	
	module.exports = Promise;


/***/ },
/* 10 */
/***/ function(module, exports) {

	'use strict';
	
	module.exports = {
	  isURI: function(uri) {
	    return uri && uri.protocol && uri.host && uri.path;
	  },
	
	  isSameOrigin: function(uri) {
	    return uri.protocol === location.protocol &&
	           uri.hostname === location.hostname &&
	           uri.port     === location.port;
	  },
	
	  parse: function(url) {
	    if (typeof url !== 'string') return url;
	    var uri = {}, parts, query, pairs, i, n, data;
	
	    var consume = function(name, pattern) {
	      url = url.replace(pattern, function(match) {
	        uri[name] = match;
	        return '';
	      });
	      uri[name] = uri[name] || '';
	    };
	
	    consume('protocol', /^[a-z]+\:/i);
	    consume('host',     /^\/\/[^\/\?#]+/);
	
	    if (!/^\//.test(url) && !uri.host)
	      url = location.pathname.replace(/[^\/]*$/, '') + url;
	
	    consume('pathname', /^[^\?#]*/);
	    consume('search',   /^\?[^#]*/);
	    consume('hash',     /^#.*/);
	
	    uri.protocol = uri.protocol || location.protocol;
	
	    if (uri.host) {
	      uri.host     = uri.host.substr(2);
	      parts        = uri.host.split(':');
	      uri.hostname = parts[0];
	      uri.port     = parts[1] || '';
	    } else {
	      uri.host     = location.host;
	      uri.hostname = location.hostname;
	      uri.port     = location.port;
	    }
	
	    uri.pathname = uri.pathname || '/';
	    uri.path = uri.pathname + uri.search;
	
	    query = uri.search.replace(/^\?/, '');
	    pairs = query ? query.split('&') : [];
	    data  = {};
	
	    for (i = 0, n = pairs.length; i < n; i++) {
	      parts = pairs[i].split('=');
	      data[decodeURIComponent(parts[0] || '')] = decodeURIComponent(parts[1] || '');
	    }
	
	    uri.query = data;
	
	    uri.href = this.stringify(uri);
	    return uri;
	  },
	
	  stringify: function(uri) {
	    var string = uri.protocol + '//' + uri.hostname;
	    if (uri.port) string += ':' + uri.port;
	    string += uri.pathname + this.queryString(uri.query) + (uri.hash || '');
	    return string;
	  },
	
	  queryString: function(query) {
	    var pairs = [];
	    for (var key in query) {
	      if (!query.hasOwnProperty(key)) continue;
	      pairs.push(encodeURIComponent(key) + '=' + encodeURIComponent(query[key]));
	    }
	    if (pairs.length === 0) return '';
	    return '?' + pairs.join('&');
	  }
	};


/***/ },
/* 11 */
/***/ function(module, exports) {

	'use strict';
	
	module.exports = {
	  commonElement: function(lista, listb) {
	    for (var i = 0, n = lista.length; i < n; i++) {
	      if (this.indexOf(listb, lista[i]) !== -1)
	        return lista[i];
	    }
	    return null;
	  },
	
	  indexOf: function(list, needle) {
	    if (list.indexOf) return list.indexOf(needle);
	
	    for (var i = 0, n = list.length; i < n; i++) {
	      if (list[i] === needle) return i;
	    }
	    return -1;
	  },
	
	  map: function(object, callback, context) {
	    if (object.map) return object.map(callback, context);
	    var result = [];
	
	    if (object instanceof Array) {
	      for (var i = 0, n = object.length; i < n; i++) {
	        result.push(callback.call(context || null, object[i], i));
	      }
	    } else {
	      for (var key in object) {
	        if (!object.hasOwnProperty(key)) continue;
	        result.push(callback.call(context || null, key, object[key]));
	      }
	    }
	    return result;
	  },
	
	  filter: function(array, callback, context) {
	    if (array.filter) return array.filter(callback, context);
	    var result = [];
	    for (var i = 0, n = array.length; i < n; i++) {
	      if (callback.call(context || null, array[i], i))
	        result.push(array[i]);
	    }
	    return result;
	  },
	
	  asyncEach: function(list, iterator, callback, context) {
	    var n       = list.length,
	        i       = -1,
	        calls   = 0,
	        looping = false;
	
	    var iterate = function() {
	      calls -= 1;
	      i += 1;
	      if (i === n) return callback && callback.call(context);
	      iterator(list[i], resume);
	    };
	
	    var loop = function() {
	      if (looping) return;
	      looping = true;
	      while (calls > 0) iterate();
	      looping = false;
	    };
	
	    var resume = function() {
	      calls += 1;
	      loop();
	    };
	    resume();
	  }
	};


/***/ },
/* 12 */
/***/ function(module, exports) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var Event = {
	  _registry: [],
	
	  on: function(element, eventName, callback, context) {
	    var wrapped = function() { callback.call(context) };
	
	    if (element.addEventListener)
	      element.addEventListener(eventName, wrapped, false);
	    else
	      element.attachEvent('on' + eventName, wrapped);
	
	    this._registry.push({
	      _element:   element,
	      _type:      eventName,
	      _callback:  callback,
	      _context:     context,
	      _handler:   wrapped
	    });
	  },
	
	  detach: function(element, eventName, callback, context) {
	    var i = this._registry.length, register;
	    while (i--) {
	      register = this._registry[i];
	
	      if ((element    && element    !== register._element)  ||
	          (eventName  && eventName  !== register._type)     ||
	          (callback   && callback   !== register._callback) ||
	          (context    && context    !== register._context))
	        continue;
	
	      if (register._element.removeEventListener)
	        register._element.removeEventListener(register._type, register._handler, false);
	      else
	        register._element.detachEvent('on' + register._type, register._handler);
	
	      this._registry.splice(i,1);
	      register = null;
	    }
	  }
	};
	
	if (global.onunload !== undefined)
	  Event.on(global, 'unload', Event.detach, Event);
	
	module.exports = {
	  Event: Event
	};
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var array = __webpack_require__(11);
	
	module.exports = function(options, validKeys) {
	  for (var key in options) {
	    if (array.indexOf(validKeys, key) < 0)
	      throw new Error('Unrecognized option: ' + key);
	  }
	};


/***/ },
/* 14 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var Promise   = __webpack_require__(9);
	
	module.exports = {
	  then: function(callback, errback) {
	    var self = this;
	    if (!this._promise)
	      this._promise = new Promise(function(resolve, reject) {
	        self._resolve = resolve;
	        self._reject  = reject;
	      });
	
	    if (arguments.length === 0)
	      return this._promise;
	    else
	      return this._promise.then(callback, errback);
	  },
	
	  callback: function(callback, context) {
	    return this.then(function(value) { callback.call(context, value) });
	  },
	
	  errback: function(callback, context) {
	    return this.then(null, function(reason) { callback.call(context, reason) });
	  },
	
	  timeout: function(seconds, message) {
	    this.then();
	    var self = this;
	    this._timer = global.setTimeout(function() {
	      self._reject(message);
	    }, seconds * 1000);
	  },
	
	  setDeferredStatus: function(status, value) {
	    if (this._timer) global.clearTimeout(this._timer);
	
	    this.then();
	
	    if (status === 'succeeded')
	      this._resolve(value);
	    else if (status === 'failed')
	      this._reject(value);
	    else
	      delete this._promise;
	  }
	};
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 15 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var extend       = __webpack_require__(8),
	    EventEmitter = __webpack_require__(16);
	
	var Publisher = {
	  countListeners: function(eventType) {
	    return this.listeners(eventType).length;
	  },
	
	  bind: function(eventType, listener, context) {
	    var slice   = Array.prototype.slice,
	        handler = function() { listener.apply(context, slice.call(arguments)) };
	
	    this._listeners = this._listeners || [];
	    this._listeners.push([eventType, listener, context, handler]);
	    return this.on(eventType, handler);
	  },
	
	  unbind: function(eventType, listener, context) {
	    this._listeners = this._listeners || [];
	    var n = this._listeners.length, tuple;
	
	    while (n--) {
	      tuple = this._listeners[n];
	      if (tuple[0] !== eventType) continue;
	      if (listener && (tuple[1] !== listener || tuple[2] !== context)) continue;
	      this._listeners.splice(n, 1);
	      this.removeListener(eventType, tuple[3]);
	    }
	  }
	};
	
	extend(Publisher, EventEmitter.prototype);
	Publisher.trigger = Publisher.emit;
	
	module.exports = Publisher;


/***/ },
/* 16 */
/***/ function(module, exports) {

	/*
	Copyright Joyent, Inc. and other Node contributors. All rights reserved.
	Permission is hereby granted, free of charge, to any person obtaining a copy of
	this software and associated documentation files (the "Software"), to deal in
	the Software without restriction, including without limitation the rights to
	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
	of the Software, and to permit persons to whom the Software is furnished to do
	so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	*/
	
	var isArray = typeof Array.isArray === 'function'
	    ? Array.isArray
	    : function (xs) {
	        return Object.prototype.toString.call(xs) === '[object Array]'
	    }
	;
	function indexOf (xs, x) {
	    if (xs.indexOf) return xs.indexOf(x);
	    for (var i = 0; i < xs.length; i++) {
	        if (x === xs[i]) return i;
	    }
	    return -1;
	}
	
	function EventEmitter() {}
	module.exports = EventEmitter;
	
	EventEmitter.prototype.emit = function(type) {
	  // If there is no 'error' event listener then throw.
	  if (type === 'error') {
	    if (!this._events || !this._events.error ||
	        (isArray(this._events.error) && !this._events.error.length))
	    {
	      if (arguments[1] instanceof Error) {
	        throw arguments[1]; // Unhandled 'error' event
	      } else {
	        throw new Error("Uncaught, unspecified 'error' event.");
	      }
	      return false;
	    }
	  }
	
	  if (!this._events) return false;
	  var handler = this._events[type];
	  if (!handler) return false;
	
	  if (typeof handler == 'function') {
	    switch (arguments.length) {
	      // fast cases
	      case 1:
	        handler.call(this);
	        break;
	      case 2:
	        handler.call(this, arguments[1]);
	        break;
	      case 3:
	        handler.call(this, arguments[1], arguments[2]);
	        break;
	      // slower
	      default:
	        var args = Array.prototype.slice.call(arguments, 1);
	        handler.apply(this, args);
	    }
	    return true;
	
	  } else if (isArray(handler)) {
	    var args = Array.prototype.slice.call(arguments, 1);
	
	    var listeners = handler.slice();
	    for (var i = 0, l = listeners.length; i < l; i++) {
	      listeners[i].apply(this, args);
	    }
	    return true;
	
	  } else {
	    return false;
	  }
	};
	
	// EventEmitter is defined in src/node_events.cc
	// EventEmitter.prototype.emit() is also defined there.
	EventEmitter.prototype.addListener = function(type, listener) {
	  if ('function' !== typeof listener) {
	    throw new Error('addListener only takes instances of Function');
	  }
	
	  if (!this._events) this._events = {};
	
	  // To avoid recursion in the case that type == "newListeners"! Before
	  // adding it to the listeners, first emit "newListeners".
	  this.emit('newListener', type, listener);
	
	  if (!this._events[type]) {
	    // Optimize the case of one listener. Don't need the extra array object.
	    this._events[type] = listener;
	  } else if (isArray(this._events[type])) {
	    // If we've already got an array, just append.
	    this._events[type].push(listener);
	  } else {
	    // Adding the second element, need to change to array.
	    this._events[type] = [this._events[type], listener];
	  }
	
	  return this;
	};
	
	EventEmitter.prototype.on = EventEmitter.prototype.addListener;
	
	EventEmitter.prototype.once = function(type, listener) {
	  var self = this;
	  self.on(type, function g() {
	    self.removeListener(type, g);
	    listener.apply(this, arguments);
	  });
	
	  return this;
	};
	
	EventEmitter.prototype.removeListener = function(type, listener) {
	  if ('function' !== typeof listener) {
	    throw new Error('removeListener only takes instances of Function');
	  }
	
	  // does not use listeners(), so no side effect of creating _events[type]
	  if (!this._events || !this._events[type]) return this;
	
	  var list = this._events[type];
	
	  if (isArray(list)) {
	    var i = indexOf(list, listener);
	    if (i < 0) return this;
	    list.splice(i, 1);
	    if (list.length == 0)
	      delete this._events[type];
	  } else if (this._events[type] === listener) {
	    delete this._events[type];
	  }
	
	  return this;
	};
	
	EventEmitter.prototype.removeAllListeners = function(type) {
	  if (arguments.length === 0) {
	    this._events = {};
	    return this;
	  }
	
	  // does not use listeners(), so no side effect of creating _events[type]
	  if (type && this._events && this._events[type]) this._events[type] = null;
	  return this;
	};
	
	EventEmitter.prototype.listeners = function(type) {
	  if (!this._events) this._events = {};
	  if (!this._events[type]) this._events[type] = [];
	  if (!isArray(this._events[type])) {
	    this._events[type] = [this._events[type]];
	  }
	  return this._events[type];
	};


/***/ },
/* 17 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var Class     = __webpack_require__(7),
	    extend    = __webpack_require__(8),
	    Publisher = __webpack_require__(15),
	    Grammar   = __webpack_require__(18);
	
	var Channel = Class({
	  initialize: function(name) {
	    this.id = this.name = name;
	  },
	
	  push: function(message) {
	    this.trigger('message', message);
	  },
	
	  isUnused: function() {
	    return this.countListeners('message') === 0;
	  }
	});
	
	extend(Channel.prototype, Publisher);
	
	extend(Channel, {
	  HANDSHAKE:    '/meta/handshake',
	  CONNECT:      '/meta/connect',
	  SUBSCRIBE:    '/meta/subscribe',
	  UNSUBSCRIBE:  '/meta/unsubscribe',
	  DISCONNECT:   '/meta/disconnect',
	
	  META:         'meta',
	  SERVICE:      'service',
	
	  expand: function(name) {
	    var segments = this.parse(name),
	        channels = ['/**', name];
	
	    var copy = segments.slice();
	    copy[copy.length - 1] = '*';
	    channels.push(this.unparse(copy));
	
	    for (var i = 1, n = segments.length; i < n; i++) {
	      copy = segments.slice(0, i);
	      copy.push('**');
	      channels.push(this.unparse(copy));
	    }
	
	    return channels;
	  },
	
	  isValid: function(name) {
	    return Grammar.CHANNEL_NAME.test(name) ||
	           Grammar.CHANNEL_PATTERN.test(name);
	  },
	
	  parse: function(name) {
	    if (!this.isValid(name)) return null;
	    return name.split('/').slice(1);
	  },
	
	  unparse: function(segments) {
	    return '/' + segments.join('/');
	  },
	
	  isMeta: function(name) {
	    var segments = this.parse(name);
	    return segments ? (segments[0] === this.META) : null;
	  },
	
	  isService: function(name) {
	    var segments = this.parse(name);
	    return segments ? (segments[0] === this.SERVICE) : null;
	  },
	
	  isSubscribable: function(name) {
	    if (!this.isValid(name)) return null;
	    return !this.isMeta(name) && !this.isService(name);
	  },
	
	  Set: Class({
	    initialize: function() {
	      this._channels = {};
	    },
	
	    getKeys: function() {
	      var keys = [];
	      for (var key in this._channels) keys.push(key);
	      return keys;
	    },
	
	    remove: function(name) {
	      delete this._channels[name];
	    },
	
	    hasSubscription: function(name) {
	      return this._channels.hasOwnProperty(name);
	    },
	
	    subscribe: function(names, subscription) {
	      var name;
	      for (var i = 0, n = names.length; i < n; i++) {
	        name = names[i];
	        var channel = this._channels[name] = this._channels[name] || new Channel(name);
	        channel.bind('message', subscription);
	      }
	    },
	
	    unsubscribe: function(name, subscription) {
	      var channel = this._channels[name];
	      if (!channel) return false;
	      channel.unbind('message', subscription);
	
	      if (channel.isUnused()) {
	        this.remove(name);
	        return true;
	      } else {
	        return false;
	      }
	    },
	
	    distributeMessage: function(message) {
	      var channels = Channel.expand(message.channel);
	
	      for (var i = 0, n = channels.length; i < n; i++) {
	        var channel = this._channels[channels[i]];
	        if (channel) channel.trigger('message', message);
	      }
	    }
	  })
	});
	
	module.exports = Channel;


/***/ },
/* 18 */
/***/ function(module, exports) {

	'use strict';
	
	module.exports = {
	  CHANNEL_NAME:     /^\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+(\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+)*$/,
	  CHANNEL_PATTERN:  /^(\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+)*\/\*{1,2}$/,
	  ERROR:            /^([0-9][0-9][0-9]:(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*(,(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*)*:(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*|[0-9][0-9][0-9]::(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*)$/,
	  VERSION:          /^([0-9])+(\.(([a-z]|[A-Z])|[0-9])(((([a-z]|[A-Z])|[0-9])|\-|\_))*)*$/
	};


/***/ },
/* 19 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var Class     = __webpack_require__(7),
	    URI       = __webpack_require__(10),
	    cookies   = __webpack_require__(20),
	    extend    = __webpack_require__(8),
	    Logging   = __webpack_require__(2),
	    Publisher = __webpack_require__(15),
	    Transport = __webpack_require__(21),
	    Scheduler = __webpack_require__(32);
	
	var Dispatcher = Class({ className: 'Dispatcher',
	  MAX_REQUEST_SIZE: 2048,
	  DEFAULT_RETRY:    5,
	
	  UP:   1,
	  DOWN: 2,
	
	  initialize: function(client, endpoint, options) {
	    this._client     = client;
	    this.endpoint    = URI.parse(endpoint);
	    this._alternates = options.endpoints || {};
	
	    this.cookies      = cookies.CookieJar && new cookies.CookieJar();
	    this._disabled    = [];
	    this._envelopes   = {};
	    this.headers      = {};
	    this.retry        = options.retry || this.DEFAULT_RETRY;
	    this._scheduler   = options.scheduler || Scheduler;
	    this._state       = 0;
	    this.transports   = {};
	    this.wsExtensions = [];
	
	    this.proxy = options.proxy || {};
	    if (typeof this._proxy === 'string') this._proxy = {origin: this._proxy};
	
	    var exts = options.websocketExtensions;
	    if (exts) {
	      exts = [].concat(exts);
	      for (var i = 0, n = exts.length; i < n; i++)
	        this.addWebsocketExtension(exts[i]);
	    }
	
	    this.tls = options.tls || {};
	    this.tls.ca = this.tls.ca || options.ca;
	
	    for (var type in this._alternates)
	      this._alternates[type] = URI.parse(this._alternates[type]);
	
	    this.maxRequestSize = this.MAX_REQUEST_SIZE;
	  },
	
	  endpointFor: function(connectionType) {
	    return this._alternates[connectionType] || this.endpoint;
	  },
	
	  addWebsocketExtension: function(extension) {
	    this.wsExtensions.push(extension);
	  },
	
	  disable: function(feature) {
	    this._disabled.push(feature);
	  },
	
	  setHeader: function(name, value) {
	    this.headers[name] = value;
	  },
	
	  close: function() {
	    var transport = this._transport;
	    delete this._transport;
	    if (transport) transport.close();
	  },
	
	  getConnectionTypes: function() {
	    return Transport.getConnectionTypes();
	  },
	
	  selectTransport: function(transportTypes) {
	    Transport.get(this, transportTypes, this._disabled, function(transport) {
	      this.debug('Selected ? transport for ?', transport.connectionType, URI.stringify(transport.endpoint));
	
	      if (transport === this._transport) return;
	      if (this._transport) this._transport.close();
	
	      this._transport = transport;
	      this.connectionType = transport.connectionType;
	    }, this);
	  },
	
	  sendMessage: function(message, timeout, options) {
	    options = options || {};
	
	    var id       = message.id,
	        attempts = options.attempts,
	        deadline = options.deadline && new Date().getTime() + (options.deadline * 1000),
	        envelope = this._envelopes[id],
	        scheduler;
	
	    if (!envelope) {
	      scheduler = new this._scheduler(message, {timeout: timeout, interval: this.retry, attempts: attempts, deadline: deadline});
	      envelope  = this._envelopes[id] = {message: message, scheduler: scheduler};
	    }
	
	    this._sendEnvelope(envelope);
	  },
	
	  _sendEnvelope: function(envelope) {
	    if (!this._transport) return;
	    if (envelope.request || envelope.timer) return;
	
	    var message   = envelope.message,
	        scheduler = envelope.scheduler,
	        self      = this;
	
	    if (!scheduler.isDeliverable()) {
	      scheduler.abort();
	      delete this._envelopes[message.id];
	      return;
	    }
	
	    envelope.timer = global.setTimeout(function() {
	      self.handleError(message);
	    }, scheduler.getTimeout() * 1000);
	
	    scheduler.send();
	    envelope.request = this._transport.sendMessage(message);
	  },
	
	  handleResponse: function(reply) {
	    var envelope = this._envelopes[reply.id];
	
	    if (reply.successful !== undefined && envelope) {
	      envelope.scheduler.succeed();
	      delete this._envelopes[reply.id];
	      global.clearTimeout(envelope.timer);
	    }
	
	    this.trigger('message', reply);
	
	    if (this._state === this.UP) return;
	    this._state = this.UP;
	    this._client.trigger('transport:up');
	  },
	
	  handleError: function(message, immediate) {
	    var envelope = this._envelopes[message.id],
	        request  = envelope && envelope.request,
	        self     = this;
	
	    if (!request) return;
	
	    request.then(function(req) {
	      if (req && req.abort) req.abort();
	    });
	
	    var scheduler = envelope.scheduler;
	    scheduler.fail();
	
	    global.clearTimeout(envelope.timer);
	    envelope.request = envelope.timer = null;
	
	    if (immediate) {
	      this._sendEnvelope(envelope);
	    } else {
	      envelope.timer = global.setTimeout(function() {
	        envelope.timer = null;
	        self._sendEnvelope(envelope);
	      }, scheduler.getInterval() * 1000);
	    }
	
	    if (this._state === this.DOWN) return;
	    this._state = this.DOWN;
	    this._client.trigger('transport:down');
	  }
	});
	
	Dispatcher.create = function(client, endpoint, options) {
	  return new Dispatcher(client, endpoint, options);
	};
	
	extend(Dispatcher.prototype, Publisher);
	extend(Dispatcher.prototype, Logging);
	
	module.exports = Dispatcher;
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 20 */
/***/ function(module, exports) {

	'use strict';
	
	module.exports = {};


/***/ },
/* 21 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var Transport = __webpack_require__(22);
	
	Transport.register('websocket', __webpack_require__(24));
	Transport.register('eventsource', __webpack_require__(28));
	Transport.register('long-polling', __webpack_require__(29));
	Transport.register('cross-origin-long-polling', __webpack_require__(30));
	Transport.register('callback-polling', __webpack_require__(31));
	
	module.exports = Transport;


/***/ },
/* 22 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var Class    = __webpack_require__(7),
	    Cookie   = __webpack_require__(20).Cookie,
	    Promise  = __webpack_require__(9),
	    URI      = __webpack_require__(10),
	    array    = __webpack_require__(11),
	    extend   = __webpack_require__(8),
	    Logging  = __webpack_require__(2),
	    Timeouts = __webpack_require__(23),
	    Channel  = __webpack_require__(17);
	
	var Transport = extend(Class({ className: 'Transport',
	  DEFAULT_PORTS: {'http:': 80, 'https:': 443, 'ws:': 80, 'wss:': 443},
	  MAX_DELAY:     0,
	
	  batching:  true,
	
	  initialize: function(dispatcher, endpoint) {
	    this._dispatcher = dispatcher;
	    this.endpoint    = endpoint;
	    this._outbox     = [];
	    this._proxy      = extend({}, this._dispatcher.proxy);
	
	    if (!this._proxy.origin)
	      this._proxy.origin = this._findProxy();
	  },
	
	  close: function() {},
	
	  encode: function(messages) {
	    return '';
	  },
	
	  sendMessage: function(message) {
	    this.debug('Client ? sending message to ?: ?',
	               this._dispatcher.clientId, URI.stringify(this.endpoint), message);
	
	    if (!this.batching) return Promise.resolve(this.request([message]));
	
	    this._outbox.push(message);
	    this._flushLargeBatch();
	
	    if (message.channel === Channel.HANDSHAKE)
	      return this._publish(0.01);
	
	    if (message.channel === Channel.CONNECT)
	      this._connectMessage = message;
	
	    return this._publish(this.MAX_DELAY);
	  },
	
	  _makePromise: function() {
	    var self = this;
	
	    this._requestPromise = this._requestPromise || new Promise(function(resolve) {
	      self._resolvePromise = resolve;
	    });
	  },
	
	  _publish: function(delay) {
	    this._makePromise();
	
	    this.addTimeout('publish', delay, function() {
	      this._flush();
	      delete this._requestPromise;
	    }, this);
	
	    return this._requestPromise;
	  },
	
	  _flush: function() {
	    this.removeTimeout('publish');
	
	    if (this._outbox.length > 1 && this._connectMessage)
	      this._connectMessage.advice = {timeout: 0};
	
	    this._resolvePromise(this.request(this._outbox));
	
	    this._connectMessage = null;
	    this._outbox = [];
	  },
	
	  _flushLargeBatch: function() {
	    var string = this.encode(this._outbox);
	    if (string.length < this._dispatcher.maxRequestSize) return;
	    var last = this._outbox.pop();
	
	    this._makePromise();
	    this._flush();
	
	    if (last) this._outbox.push(last);
	  },
	
	  _receive: function(replies) {
	    if (!replies) return;
	    replies = [].concat(replies);
	
	    this.debug('Client ? received from ? via ?: ?',
	               this._dispatcher.clientId, URI.stringify(this.endpoint), this.connectionType, replies);
	
	    for (var i = 0, n = replies.length; i < n; i++)
	      this._dispatcher.handleResponse(replies[i]);
	  },
	
	  _handleError: function(messages, immediate) {
	    messages = [].concat(messages);
	
	    this.debug('Client ? failed to send to ? via ?: ?',
	               this._dispatcher.clientId, URI.stringify(this.endpoint), this.connectionType, messages);
	
	    for (var i = 0, n = messages.length; i < n; i++)
	      this._dispatcher.handleError(messages[i]);
	  },
	
	  _getCookies: function() {
	    var cookies = this._dispatcher.cookies,
	        url     = URI.stringify(this.endpoint);
	
	    if (!cookies) return '';
	
	    return array.map(cookies.getCookiesSync(url), function(cookie) {
	      return cookie.cookieString();
	    }).join('; ');
	  },
	
	  _storeCookies: function(setCookie) {
	    var cookies = this._dispatcher.cookies,
	        url     = URI.stringify(this.endpoint),
	        cookie;
	
	    if (!setCookie || !cookies) return;
	    setCookie = [].concat(setCookie);
	
	    for (var i = 0, n = setCookie.length; i < n; i++) {
	      cookie = Cookie.parse(setCookie[i]);
	      cookies.setCookieSync(cookie, url);
	    }
	  },
	
	  _findProxy: function() {
	    if (typeof process === 'undefined') return undefined;
	
	    var protocol = this.endpoint.protocol;
	    if (!protocol) return undefined;
	
	    var name   = protocol.replace(/:$/, '').toLowerCase() + '_proxy',
	        upcase = name.toUpperCase(),
	        env    = process.env,
	        keys, proxy;
	
	    if (name === 'http_proxy' && env.REQUEST_METHOD) {
	      keys = Object.keys(env).filter(function(k) { return /^http_proxy$/i.test(k) });
	      if (keys.length === 1) {
	        if (keys[0] === name && env[upcase] === undefined)
	          proxy = env[name];
	      } else if (keys.length > 1) {
	        proxy = env[name];
	      }
	      proxy = proxy || env['CGI_' + upcase];
	    } else {
	      proxy = env[name] || env[upcase];
	      if (proxy && !env[name])
	        console.warn('The environment variable ' + upcase +
	                     ' is discouraged. Use ' + name + '.');
	    }
	    return proxy;
	  }
	
	}), {
	  get: function(dispatcher, allowed, disabled, callback, context) {
	    var endpoint = dispatcher.endpoint;
	
	    array.asyncEach(this._transports, function(pair, resume) {
	      var connType     = pair[0], klass = pair[1],
	          connEndpoint = dispatcher.endpointFor(connType);
	
	      if (array.indexOf(disabled, connType) >= 0)
	        return resume();
	
	      if (array.indexOf(allowed, connType) < 0) {
	        klass.isUsable(dispatcher, connEndpoint, function() {});
	        return resume();
	      }
	
	      klass.isUsable(dispatcher, connEndpoint, function(isUsable) {
	        if (!isUsable) return resume();
	        var transport = klass.hasOwnProperty('create') ? klass.create(dispatcher, connEndpoint) : new klass(dispatcher, connEndpoint);
	        callback.call(context, transport);
	      });
	    }, function() {
	      throw new Error('Could not find a usable connection type for ' + URI.stringify(endpoint));
	    });
	  },
	
	  register: function(type, klass) {
	    this._transports.push([type, klass]);
	    klass.prototype.connectionType = type;
	  },
	
	  getConnectionTypes: function() {
	    return array.map(this._transports, function(t) { return t[0] });
	  },
	
	  _transports: []
	});
	
	extend(Transport.prototype, Logging);
	extend(Transport.prototype, Timeouts);
	
	module.exports = Transport;


/***/ },
/* 23 */
/***/ function(module, exports) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	module.exports = {
	  addTimeout: function(name, delay, callback, context) {
	    this._timeouts = this._timeouts || {};
	    if (this._timeouts.hasOwnProperty(name)) return;
	    var self = this;
	    this._timeouts[name] = global.setTimeout(function() {
	      delete self._timeouts[name];
	      callback.call(context);
	    }, 1000 * delay);
	  },
	
	  removeTimeout: function(name) {
	    this._timeouts = this._timeouts || {};
	    var timeout = this._timeouts[name];
	    if (!timeout) return;
	    global.clearTimeout(timeout);
	    delete this._timeouts[name];
	  },
	
	  removeAllTimeouts: function() {
	    this._timeouts = this._timeouts || {};
	    for (var name in this._timeouts) this.removeTimeout(name);
	  }
	};
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 24 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var Class      = __webpack_require__(7),
	    Promise    = __webpack_require__(9),
	    Set        = __webpack_require__(25),
	    URI        = __webpack_require__(10),
	    browser    = __webpack_require__(12),
	    copyObject = __webpack_require__(26),
	    extend     = __webpack_require__(8),
	    toJSON     = __webpack_require__(3),
	    ws         = __webpack_require__(27),
	    Deferrable = __webpack_require__(14),
	    Transport  = __webpack_require__(22);
	
	var WebSocket = extend(Class(Transport, {
	  UNCONNECTED:  1,
	  CONNECTING:   2,
	  CONNECTED:    3,
	
	  batching:     false,
	
	  isUsable: function(callback, context) {
	    this.callback(function() { callback.call(context, true) });
	    this.errback(function() { callback.call(context, false) });
	    this.connect();
	  },
	
	  request: function(messages) {
	    this._pending = this._pending || new Set();
	    for (var i = 0, n = messages.length; i < n; i++) this._pending.add(messages[i]);
	
	    var self = this;
	
	    var promise = new Promise(function(resolve, reject) {
	      self.callback(function(socket) {
	        if (!socket || socket.readyState !== 1) return;
	        socket.send(toJSON(messages));
	        resolve(socket);
	      });
	
	      self.connect();
	    });
	
	    return {
	      abort: function() { promise.then(function(ws) { ws.close() }) }
	    };
	  },
	
	  connect: function() {
	    if (WebSocket._unloaded) return;
	
	    this._state = this._state || this.UNCONNECTED;
	    if (this._state !== this.UNCONNECTED) return;
	    this._state = this.CONNECTING;
	
	    var socket = this._createSocket();
	    if (!socket) return this.setDeferredStatus('failed');
	
	    var self = this;
	
	    socket.onopen = function() {
	      if (socket.headers) self._storeCookies(socket.headers['set-cookie']);
	      self._socket = socket;
	      self._state = self.CONNECTED;
	      self._everConnected = true;
	      self._ping();
	      self.setDeferredStatus('succeeded', socket);
	    };
	
	    var closed = false;
	    socket.onclose = socket.onerror = function() {
	      if (closed) return;
	      closed = true;
	
	      var wasConnected = (self._state === self.CONNECTED);
	      socket.onopen = socket.onclose = socket.onerror = socket.onmessage = null;
	
	      delete self._socket;
	      self._state = self.UNCONNECTED;
	      self.removeTimeout('ping');
	
	      var pending = self._pending ? self._pending.toArray() : [];
	      delete self._pending;
	
	      if (wasConnected || self._everConnected) {
	        self.setDeferredStatus('unknown');
	        self._handleError(pending, wasConnected);
	      } else {
	        self.setDeferredStatus('failed');
	      }
	    };
	
	    socket.onmessage = function(event) {
	      var replies;
	      try { replies = JSON.parse(event.data) } catch (error) {}
	
	      if (!replies) return;
	
	      replies = [].concat(replies);
	
	      for (var i = 0, n = replies.length; i < n; i++) {
	        if (replies[i].successful === undefined) continue;
	        self._pending.remove(replies[i]);
	      }
	      self._receive(replies);
	    };
	  },
	
	  close: function() {
	    if (!this._socket) return;
	    this._socket.close();
	  },
	
	  _createSocket: function() {
	    var url        = WebSocket.getSocketUrl(this.endpoint),
	        headers    = this._dispatcher.headers,
	        extensions = this._dispatcher.wsExtensions,
	        cookie     = this._getCookies(),
	        tls        = this._dispatcher.tls,
	        options    = {extensions: extensions, headers: headers, proxy: this._proxy, tls: tls};
	
	    if (cookie !== '') options.headers['Cookie'] = cookie;
	
	    return ws.create(url, [], options);
	  },
	
	  _ping: function() {
	    if (!this._socket || this._socket.readyState !== 1) return;
	    this._socket.send('[]');
	    this.addTimeout('ping', this._dispatcher.timeout / 2, this._ping, this);
	  }
	
	}), {
	  PROTOCOLS: {
	    'http:':  'ws:',
	    'https:': 'wss:'
	  },
	
	  create: function(dispatcher, endpoint) {
	    var sockets = dispatcher.transports.websocket = dispatcher.transports.websocket || {};
	    sockets[endpoint.href] = sockets[endpoint.href] || new this(dispatcher, endpoint);
	    return sockets[endpoint.href];
	  },
	
	  getSocketUrl: function(endpoint) {
	    endpoint = copyObject(endpoint);
	    endpoint.protocol = this.PROTOCOLS[endpoint.protocol];
	    return URI.stringify(endpoint);
	  },
	
	  isUsable: function(dispatcher, endpoint, callback, context) {
	    this.create(dispatcher, endpoint).isUsable(callback, context);
	  }
	});
	
	extend(WebSocket.prototype, Deferrable);
	
	if (browser.Event && global.onbeforeunload !== undefined)
	  browser.Event.on(global, 'beforeunload', function() { WebSocket._unloaded = true });
	
	module.exports = WebSocket;
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 25 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var Class = __webpack_require__(7);
	
	module.exports = Class({
	  initialize: function() {
	    this._index = {};
	  },
	
	  add: function(item) {
	    var key = (item.id !== undefined) ? item.id : item;
	    if (this._index.hasOwnProperty(key)) return false;
	    this._index[key] = item;
	    return true;
	  },
	
	  forEach: function(block, context) {
	    for (var key in this._index) {
	      if (this._index.hasOwnProperty(key))
	        block.call(context, this._index[key]);
	    }
	  },
	
	  isEmpty: function() {
	    for (var key in this._index) {
	      if (this._index.hasOwnProperty(key)) return false;
	    }
	    return true;
	  },
	
	  member: function(item) {
	    for (var key in this._index) {
	      if (this._index[key] === item) return true;
	    }
	    return false;
	  },
	
	  remove: function(item) {
	    var key = (item.id !== undefined) ? item.id : item;
	    var removed = this._index[key];
	    delete this._index[key];
	    return removed;
	  },
	
	  toArray: function() {
	    var array = [];
	    this.forEach(function(item) { array.push(item) });
	    return array;
	  }
	});


/***/ },
/* 26 */
/***/ function(module, exports) {

	'use strict';
	
	var copyObject = function(object) {
	  var clone, i, key;
	  if (object instanceof Array) {
	    clone = [];
	    i = object.length;
	    while (i--) clone[i] = copyObject(object[i]);
	    return clone;
	  } else if (typeof object === 'object') {
	    clone = (object === null) ? null : {};
	    for (key in object) clone[key] = copyObject(object[key]);
	    return clone;
	  } else {
	    return object;
	  }
	};
	
	module.exports = copyObject;


/***/ },
/* 27 */
/***/ function(module, exports) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var WS = global.MozWebSocket || global.WebSocket;
	
	module.exports = {
	  create: function(url, protocols, options) {
	    if (typeof WS !== 'function') return null;
	    return new WS(url);
	  }
	};
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 28 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var Class      = __webpack_require__(7),
	    URI        = __webpack_require__(10),
	    copyObject = __webpack_require__(26),
	    extend     = __webpack_require__(8),
	    Deferrable = __webpack_require__(14),
	    Transport  = __webpack_require__(22),
	    XHR        = __webpack_require__(29);
	
	var EventSource = extend(Class(Transport, {
	  initialize: function(dispatcher, endpoint) {
	    Transport.prototype.initialize.call(this, dispatcher, endpoint);
	    if (!global.EventSource) return this.setDeferredStatus('failed');
	
	    this._xhr = new XHR(dispatcher, endpoint);
	
	    endpoint = copyObject(endpoint);
	    endpoint.pathname += '/' + dispatcher.clientId;
	
	    var socket = new global.EventSource(URI.stringify(endpoint)),
	        self   = this;
	
	    socket.onopen = function() {
	      self._everConnected = true;
	      self.setDeferredStatus('succeeded');
	    };
	
	    socket.onerror = function() {
	      if (self._everConnected) {
	        self._handleError([]);
	      } else {
	        self.setDeferredStatus('failed');
	        socket.close();
	      }
	    };
	
	    socket.onmessage = function(event) {
	      var replies;
	      try { replies = JSON.parse(event.data) } catch (error) {}
	
	      if (replies)
	        self._receive(replies);
	      else
	        self._handleError([]);
	    };
	
	    this._socket = socket;
	  },
	
	  close: function() {
	    if (!this._socket) return;
	    this._socket.onopen = this._socket.onerror = this._socket.onmessage = null;
	    this._socket.close();
	    delete this._socket;
	  },
	
	  isUsable: function(callback, context) {
	    this.callback(function() { callback.call(context, true) });
	    this.errback(function() { callback.call(context, false) });
	  },
	
	  encode: function(messages) {
	    return this._xhr.encode(messages);
	  },
	
	  request: function(messages) {
	    return this._xhr.request(messages);
	  }
	
	}), {
	  isUsable: function(dispatcher, endpoint, callback, context) {
	    var id = dispatcher.clientId;
	    if (!id) return callback.call(context, false);
	
	    XHR.isUsable(dispatcher, endpoint, function(usable) {
	      if (!usable) return callback.call(context, false);
	      this.create(dispatcher, endpoint).isUsable(callback, context);
	    }, this);
	  },
	
	  create: function(dispatcher, endpoint) {
	    var sockets = dispatcher.transports.eventsource = dispatcher.transports.eventsource || {},
	        id      = dispatcher.clientId;
	
	    var url = copyObject(endpoint);
	    url.pathname += '/' + (id || '');
	    url = URI.stringify(url);
	
	    sockets[url] = sockets[url] || new this(dispatcher, endpoint);
	    return sockets[url];
	  }
	});
	
	extend(EventSource.prototype, Deferrable);
	
	module.exports = EventSource;
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 29 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var Class     = __webpack_require__(7),
	    URI       = __webpack_require__(10),
	    browser   = __webpack_require__(12),
	    extend    = __webpack_require__(8),
	    toJSON    = __webpack_require__(3),
	    Transport = __webpack_require__(22);
	
	var XHR = extend(Class(Transport, {
	  encode: function(messages) {
	    return toJSON(messages);
	  },
	
	  request: function(messages) {
	    var href = this.endpoint.href,
	        self = this,
	        xhr;
	
	    // Prefer XMLHttpRequest over ActiveXObject if they both exist
	    if (global.XMLHttpRequest) {
	      xhr = new XMLHttpRequest();
	    } else if (global.ActiveXObject) {
	      xhr = new ActiveXObject('Microsoft.XMLHTTP');
	    } else {
	      return this._handleError(messages);
	    }
	
	    xhr.open('POST', href, true);
	    xhr.setRequestHeader('Content-Type', 'application/json');
	    xhr.setRequestHeader('Pragma', 'no-cache');
	    xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
	
	    var headers = this._dispatcher.headers;
	    for (var key in headers) {
	      if (!headers.hasOwnProperty(key)) continue;
	      xhr.setRequestHeader(key, headers[key]);
	    }
	
	    var abort = function() { xhr.abort() };
	    if (global.onbeforeunload !== undefined)
	      browser.Event.on(global, 'beforeunload', abort);
	
	    xhr.onreadystatechange = function() {
	      if (!xhr || xhr.readyState !== 4) return;
	
	      var replies    = null,
	          status     = xhr.status,
	          text       = xhr.responseText,
	          successful = (status >= 200 && status < 300) || status === 304 || status === 1223;
	
	      if (global.onbeforeunload !== undefined)
	        browser.Event.detach(global, 'beforeunload', abort);
	
	      xhr.onreadystatechange = function() {};
	      xhr = null;
	
	      if (!successful) return self._handleError(messages);
	
	      try {
	        replies = JSON.parse(text);
	      } catch (error) {}
	
	      if (replies)
	        self._receive(replies);
	      else
	        self._handleError(messages);
	    };
	
	    xhr.send(this.encode(messages));
	    return xhr;
	  }
	}), {
	  isUsable: function(dispatcher, endpoint, callback, context) {
	    var usable = (navigator.product === 'ReactNative')
	              || URI.isSameOrigin(endpoint);
	
	    callback.call(context, usable);
	  }
	});
	
	module.exports = XHR;
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 30 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var Class     = __webpack_require__(7),
	    Set       = __webpack_require__(25),
	    URI       = __webpack_require__(10),
	    extend    = __webpack_require__(8),
	    toJSON    = __webpack_require__(3),
	    Transport = __webpack_require__(22);
	
	var CORS = extend(Class(Transport, {
	  encode: function(messages) {
	    return 'message=' + encodeURIComponent(toJSON(messages));
	  },
	
	  request: function(messages) {
	    var xhrClass = global.XDomainRequest ? XDomainRequest : XMLHttpRequest,
	        xhr      = new xhrClass(),
	        id       = ++CORS._id,
	        headers  = this._dispatcher.headers,
	        self     = this,
	        key;
	
	    xhr.open('POST', URI.stringify(this.endpoint), true);
	
	    if (xhr.setRequestHeader) {
	      xhr.setRequestHeader('Pragma', 'no-cache');
	      for (key in headers) {
	        if (!headers.hasOwnProperty(key)) continue;
	        xhr.setRequestHeader(key, headers[key]);
	      }
	    }
	
	    var cleanUp = function() {
	      if (!xhr) return false;
	      CORS._pending.remove(id);
	      xhr.onload = xhr.onerror = xhr.ontimeout = xhr.onprogress = null;
	      xhr = null;
	    };
	
	    xhr.onload = function() {
	      var replies;
	      try { replies = JSON.parse(xhr.responseText) } catch (error) {}
	
	      cleanUp();
	
	      if (replies)
	        self._receive(replies);
	      else
	        self._handleError(messages);
	    };
	
	    xhr.onerror = xhr.ontimeout = function() {
	      cleanUp();
	      self._handleError(messages);
	    };
	
	    xhr.onprogress = function() {};
	
	    if (xhrClass === global.XDomainRequest)
	      CORS._pending.add({id: id, xhr: xhr});
	
	    xhr.send(this.encode(messages));
	    return xhr;
	  }
	}), {
	  _id:      0,
	  _pending: new Set(),
	
	  isUsable: function(dispatcher, endpoint, callback, context) {
	    if (URI.isSameOrigin(endpoint))
	      return callback.call(context, false);
	
	    if (global.XDomainRequest)
	      return callback.call(context, endpoint.protocol === location.protocol);
	
	    if (global.XMLHttpRequest) {
	      var xhr = new XMLHttpRequest();
	      return callback.call(context, xhr.withCredentials !== undefined);
	    }
	    return callback.call(context, false);
	  }
	});
	
	module.exports = CORS;
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 31 */
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {'use strict';
	
	var Class      = __webpack_require__(7),
	    URI        = __webpack_require__(10),
	    copyObject = __webpack_require__(26),
	    extend     = __webpack_require__(8),
	    toJSON     = __webpack_require__(3),
	    Transport  = __webpack_require__(22);
	
	var JSONP = extend(Class(Transport, {
	 encode: function(messages) {
	    var url = copyObject(this.endpoint);
	    url.query.message = toJSON(messages);
	    url.query.jsonp   = '__jsonp' + JSONP._cbCount + '__';
	    return URI.stringify(url);
	  },
	
	  request: function(messages) {
	    var head         = document.getElementsByTagName('head')[0],
	        script       = document.createElement('script'),
	        callbackName = JSONP.getCallbackName(),
	        endpoint     = copyObject(this.endpoint),
	        self         = this;
	
	    endpoint.query.message = toJSON(messages);
	    endpoint.query.jsonp   = callbackName;
	
	    var cleanup = function() {
	      if (!global[callbackName]) return false;
	      global[callbackName] = undefined;
	      try { delete global[callbackName] } catch (error) {}
	      script.parentNode.removeChild(script);
	    };
	
	    global[callbackName] = function(replies) {
	      cleanup();
	      self._receive(replies);
	    };
	
	    script.type = 'text/javascript';
	    script.src  = URI.stringify(endpoint);
	    head.appendChild(script);
	
	    script.onerror = function() {
	      cleanup();
	      self._handleError(messages);
	    };
	
	    return {abort: cleanup};
	  }
	}), {
	  _cbCount: 0,
	
	  getCallbackName: function() {
	    this._cbCount += 1;
	    return '__jsonp' + this._cbCount + '__';
	  },
	
	  isUsable: function(dispatcher, endpoint, callback, context) {
	    callback.call(context, true);
	  }
	});
	
	module.exports = JSONP;
	
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },
/* 32 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var extend = __webpack_require__(8);
	
	var Scheduler = function(message, options) {
	  this.message  = message;
	  this.options  = options;
	  this.attempts = 0;
	};
	
	extend(Scheduler.prototype, {
	  getTimeout: function() {
	    return this.options.timeout;
	  },
	
	  getInterval: function() {
	    return this.options.interval;
	  },
	
	  isDeliverable: function() {
	    var attempts = this.options.attempts,
	        made     = this.attempts,
	        deadline = this.options.deadline,
	        now      = new Date().getTime();
	
	    if (attempts !== undefined && made >= attempts)
	      return false;
	
	    if (deadline !== undefined && now > deadline)
	      return false;
	
	    return true;
	  },
	
	  send: function() {
	    this.attempts += 1;
	  },
	
	  succeed: function() {},
	
	  fail: function() {},
	
	  abort: function() {}
	});
	
	module.exports = Scheduler;


/***/ },
/* 33 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var Class   = __webpack_require__(7),
	    Grammar = __webpack_require__(18);
	
	var Error = Class({
	  initialize: function(code, params, message) {
	    this.code    = code;
	    this.params  = Array.prototype.slice.call(params);
	    this.message = message;
	  },
	
	  toString: function() {
	    return this.code + ':' +
	           this.params.join(',') + ':' +
	           this.message;
	  }
	});
	
	Error.parse = function(message) {
	  message = message || '';
	  if (!Grammar.ERROR.test(message)) return new Error(null, [], message);
	
	  var parts   = message.split(':'),
	      code    = parseInt(parts[0]),
	      params  = parts[1].split(','),
	      message = parts[2];
	
	  return new Error(code, params, message);
	};
	
	// http://code.google.com/p/cometd/wiki/BayeuxCodes
	var errors = {
	  versionMismatch:  [300, 'Version mismatch'],
	  conntypeMismatch: [301, 'Connection types not supported'],
	  extMismatch:      [302, 'Extension mismatch'],
	  badRequest:       [400, 'Bad request'],
	  clientUnknown:    [401, 'Unknown client'],
	  parameterMissing: [402, 'Missing required parameter'],
	  channelForbidden: [403, 'Forbidden channel'],
	  channelUnknown:   [404, 'Unknown channel'],
	  channelInvalid:   [405, 'Invalid channel'],
	  extUnknown:       [406, 'Unknown extension'],
	  publishFailed:    [407, 'Failed to publish'],
	  serverError:      [500, 'Internal server error']
	};
	
	for (var name in errors)
	  (function(name) {
	    Error[name] = function() {
	      return new Error(errors[name][0], arguments, errors[name][1]).toString();
	    };
	  })(name);
	
	module.exports = Error;


/***/ },
/* 34 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var extend  = __webpack_require__(8),
	    Logging = __webpack_require__(2);
	
	var Extensible = {
	  addExtension: function(extension) {
	    this._extensions = this._extensions || [];
	    this._extensions.push(extension);
	    if (extension.added) extension.added(this);
	  },
	
	  removeExtension: function(extension) {
	    if (!this._extensions) return;
	    var i = this._extensions.length;
	    while (i--) {
	      if (this._extensions[i] !== extension) continue;
	      this._extensions.splice(i,1);
	      if (extension.removed) extension.removed(this);
	    }
	  },
	
	  pipeThroughExtensions: function(stage, message, request, callback, context) {
	    this.debug('Passing through ? extensions: ?', stage, message);
	
	    if (!this._extensions) return callback.call(context, message);
	    var extensions = this._extensions.slice();
	
	    var pipe = function(message) {
	      if (!message) return callback.call(context, message);
	
	      var extension = extensions.shift();
	      if (!extension) return callback.call(context, message);
	
	      var fn = extension[stage];
	      if (!fn) return pipe(message);
	
	      if (fn.length >= 3) extension[stage](message, request, pipe);
	      else                extension[stage](message, pipe);
	    };
	    pipe(message);
	  }
	};
	
	extend(Extensible, Logging);
	
	module.exports = Extensible;


/***/ },
/* 35 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var Class      = __webpack_require__(7),
	    Deferrable = __webpack_require__(14);
	
	module.exports = Class(Deferrable);


/***/ },
/* 36 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	
	var Class      = __webpack_require__(7),
	    extend     = __webpack_require__(8),
	    Deferrable = __webpack_require__(14);
	
	var Subscription = Class({
	  initialize: function(client, channels, callback, context) {
	    this._client    = client;
	    this._channels  = channels;
	    this._callback  = callback;
	    this._context   = context;
	    this._cancelled = false;
	  },
	
	  withChannel: function(callback, context) {
	    this._withChannel = [callback, context];
	    return this;
	  },
	
	  apply: function(context, args) {
	    var message = args[0];
	
	    if (this._callback)
	      this._callback.call(this._context, message.data);
	
	    if (this._withChannel)
	      this._withChannel[0].call(this._withChannel[1], message.channel, message.data);
	  },
	
	  cancel: function() {
	    if (this._cancelled) return;
	    this._client.unsubscribe(this._channels, this);
	    this._cancelled = true;
	  },
	
	  unsubscribe: function() {
	    this.cancel();
	  }
	});
	
	extend(Subscription.prototype, Deferrable);
	
	module.exports = Subscription;


/***/ }
/******/ ]);
//# sourceMappingURL=faye-browser.js.map
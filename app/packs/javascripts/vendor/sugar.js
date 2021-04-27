/*
 *  Sugar Custom 2017.05.06
 *
 *  Freely distributable and licensed under the MIT-style license.
 *  Copyright (c)  Andrew Plummer
 *  https://sugarjs.com/
 *
 * ---------------------------- */
(function() {
  'use strict';

  /***
   * @module Core
   * @description Core functionality including the ability to define methods and
   *              extend onto natives.
   *
   ***/

  // The global to export.
  var Sugar;

  // The name of Sugar in the global namespace.
  var SUGAR_GLOBAL = 'Sugar';

  // Natives available on initialization. Letting Object go first to ensure its
  // global is set by the time the rest are checking for chainable Object methods.
  var NATIVE_NAMES = 'Object Number String Array Date RegExp Function';

  // Static method flag
  var STATIC   = 0x1;

  // Instance method flag
  var INSTANCE = 0x2;

  // IE8 has a broken defineProperty but no defineProperties so this saves a try/catch.
  var PROPERTY_DESCRIPTOR_SUPPORT = !!(Object.defineProperty && Object.defineProperties);

  // The global context. Rhino uses a different "global" keyword so
  // do an extra check to be sure that it's actually the global context.
  var globalContext = typeof global !== 'undefined' && global.Object === Object ? global : this;

  // Is the environment node?
  var hasExports = typeof module !== 'undefined' && module.exports;

  // Whether object instance methods can be mapped to the prototype.
  var allowObjectPrototype = false;

  // A map from Array to SugarArray.
  var namespacesByName = {};

  // A map from [object Object] to namespace.
  var namespacesByClassString = {};

  // Defining properties.
  var defineProperty = PROPERTY_DESCRIPTOR_SUPPORT ?  Object.defineProperty : definePropertyShim;

  // A default chainable class for unknown types.
  var DefaultChainable = getNewChainableClass('Chainable');


  // Global methods

  function setupGlobal() {
    Sugar = globalContext[SUGAR_GLOBAL];
    // istanbul ignore if
    if (Sugar) {
      // Reuse already defined Sugar global object.
      return;
    }
    Sugar = function(arg) {
      forEachProperty(Sugar, function(sugarNamespace, name) {
        // Although only the only enumerable properties on the global
        // object are Sugar namespaces, environments that can't set
        // non-enumerable properties will step through the utility methods
        // as well here, so use this check to only allow true namespaces.
        if (hasOwn(namespacesByName, name)) {
          sugarNamespace.extend(arg);
        }
      });
      return Sugar;
    };
    // istanbul ignore else
    if (hasExports) {
      module.exports = Sugar;
    } else {
      try {
        globalContext[SUGAR_GLOBAL] = Sugar;
      } catch (e) {
        // Contexts such as QML have a read-only global context.
      }
    }
    forEachProperty(NATIVE_NAMES.split(' '), function(name) {
      createNamespace(name);
    });
    setGlobalProperties();
  }

  /***
   * @method createNamespace(name)
   * @returns SugarNamespace
   * @namespace Sugar
   * @short Creates a new Sugar namespace.
   * @extra This method is for plugin developers who want to define methods to be
   *        used with natives that Sugar does not handle by default. The new
   *        namespace will appear on the `Sugar` global with all the methods of
   *        normal namespaces, including the ability to define new methods. When
   *        extended, any defined methods will be mapped to `name` in the global
   *        context.
   *
   * @example
   *
   *   Sugar.createNamespace('Boolean');
   *
   * @param {string} name - The namespace name.
   *
   ***/
  function createNamespace(name) {

    // Is the current namespace Object?
    var isObject = name === 'Object';

    // A Sugar namespace is also a chainable class: Sugar.Array, etc.
    var sugarNamespace = getNewChainableClass(name, true);

    /***
     * @method extend([opts])
     * @returns Sugar
     * @namespace Sugar
     * @short Extends Sugar defined methods onto natives.
     * @extra This method can be called on individual namespaces like
     *        `Sugar.Array` or on the `Sugar` global itself, in which case
     *        [opts] will be forwarded to each `extend` call. For more,
     *        see `extending`.
     *
     * @options
     *
     *   methods           An array of method names to explicitly extend.
     *
     *   except            An array of method names or global namespaces (`Array`,
     *                     `String`) to explicitly exclude. Namespaces should be the
     *                     actual global objects, not strings.
     *
     *   namespaces        An array of global namespaces (`Array`, `String`) to
     *                     explicitly extend. Namespaces should be the actual
     *                     global objects, not strings.
     *
     *   enhance           A shortcut to disallow all "enhance" flags at once
     *                     (flags listed below). For more, see `enhanced methods`.
     *                     Default is `true`.
     *
     *   enhanceString     A boolean allowing String enhancements. Default is `true`.
     *
     *   enhanceArray      A boolean allowing Array enhancements. Default is `true`.
     *
     *   objectPrototype   A boolean allowing Sugar to extend Object.prototype
     *                     with instance methods. This option is off by default
     *                     and should generally not be used except with caution.
     *                     For more, see `object methods`.
     *
     * @example
     *
     *   Sugar.Array.extend();
     *   Sugar.extend();
     *
     * @option {Array<string>} [methods]
     * @option {Array<string|NativeConstructor>} [except]
     * @option {Array<NativeConstructor>} [namespaces]
     * @option {boolean} [enhance]
     * @option {boolean} [enhanceString]
     * @option {boolean} [enhanceArray]
     * @option {boolean} [objectPrototype]
     * @param {ExtendOptions} [opts]
     *
     ***
     * @method extend([opts])
     * @returns SugarNamespace
     * @namespace SugarNamespace
     * @short Extends Sugar defined methods for a specific namespace onto natives.
     * @param {ExtendOptions} [opts]
     *
     ***/
    var extend = function (opts) {

      var nativeClass = globalContext[name], nativeProto = nativeClass.prototype;
      var staticMethods = {}, instanceMethods = {}, methodsByName;

      function objectRestricted(name, target) {
        return isObject && target === nativeProto &&
               (!allowObjectPrototype || name === 'get' || name === 'set');
      }

      function arrayOptionExists(field, val) {
        var arr = opts[field];
        if (arr) {
          for (var i = 0, el; el = arr[i]; i++) {
            if (el === val) {
              return true;
            }
          }
        }
        return false;
      }

      function arrayOptionExcludes(field, val) {
        return opts[field] && !arrayOptionExists(field, val);
      }

      function disallowedByFlags(methodName, target, flags) {
        // Disallowing methods by flag currently only applies if methods already
        // exist to avoid enhancing native methods, as aliases should still be
        // extended (i.e. Array#all should still be extended even if Array#every
        // is being disallowed by a flag).
        if (!target[methodName] || !flags) {
          return false;
        }
        for (var i = 0; i < flags.length; i++) {
          if (opts[flags[i]] === false) {
            return true;
          }
        }
      }

      function namespaceIsExcepted() {
        return arrayOptionExists('except', nativeClass) ||
               arrayOptionExcludes('namespaces', nativeClass);
      }

      function methodIsExcepted(methodName) {
        return arrayOptionExists('except', methodName);
      }

      function canExtend(methodName, method, target) {
        return !objectRestricted(methodName, target) &&
               !disallowedByFlags(methodName, target, method.flags) &&
               !methodIsExcepted(methodName);
      }

      opts = opts || {};
      methodsByName = opts.methods;

      if (namespaceIsExcepted()) {
        return;
      } else if (isObject && typeof opts.objectPrototype === 'boolean') {
        // Store "objectPrototype" flag for future reference.
        allowObjectPrototype = opts.objectPrototype;
      }

      forEachProperty(methodsByName || sugarNamespace, function(method, methodName) {
        if (methodsByName) {
          // If we have method names passed in an array,
          // then we need to flip the key and value here
          // and find the method in the Sugar namespace.
          methodName = method;
          method = sugarNamespace[methodName];
        }
        if (hasOwn(method, 'instance') && canExtend(methodName, method, nativeProto)) {
          instanceMethods[methodName] = method.instance;
        }
        if(hasOwn(method, 'static') && canExtend(methodName, method, nativeClass)) {
          staticMethods[methodName] = method;
        }
      });

      // Accessing the extend target each time instead of holding a reference as
      // it may have been overwritten (for example Date by Sinon). Also need to
      // access through the global to allow extension of user-defined namespaces.
      extendNative(nativeClass, staticMethods);
      extendNative(nativeProto, instanceMethods);

      if (!methodsByName) {
        // If there are no method names passed, then
        // all methods in the namespace will be extended
        // to the native. This includes all future defined
        // methods, so add a flag here to check later.
        setProperty(sugarNamespace, 'active', true);
      }
      return sugarNamespace;
    };

    function defineWithOptionCollect(methodName, instance, args) {
      setProperty(sugarNamespace, methodName, function(arg1, arg2, arg3) {
        var opts = collectDefineOptions(arg1, arg2, arg3);
        defineMethods(sugarNamespace, opts.methods, instance, args, opts.last);
        return sugarNamespace;
      });
    }

    /***
     * @method defineStatic(methods)
     * @returns SugarNamespace
     * @namespace SugarNamespace
     * @short Defines static methods on the namespace that can later be extended
     *        onto the native globals.
     * @extra Accepts either a single object mapping names to functions, or name
     *        and function as two arguments. If `extend` was previously called
     *        with no arguments, the method will be immediately mapped to its
     *        native when defined.
     *
     * @example
     *
     *   Sugar.Number.defineStatic({
     *     isOdd: function (num) {
     *       return num % 2 === 1;
     *     }
     *   });
     *
     * @signature defineStatic(methodName, methodFn)
     * @param {Object} methods - Methods to be defined.
     * @param {string} methodName - Name of a single method to be defined.
     * @param {Function} methodFn - Function body of a single method to be defined.
     ***/
    defineWithOptionCollect('defineStatic', STATIC);

    /***
     * @method defineInstance(methods)
     * @returns SugarNamespace
     * @namespace SugarNamespace
     * @short Defines methods on the namespace that can later be extended as
     *        instance methods onto the native prototype.
     * @extra Accepts either a single object mapping names to functions, or name
     *        and function as two arguments. All functions should accept the
     *        native for which they are mapped as their first argument, and should
     *        never refer to `this`. If `extend` was previously called with no
     *        arguments, the method will be immediately mapped to its native when
     *        defined.
     *
     *        Methods cannot accept more than 4 arguments in addition to the
     *        native (5 arguments total). Any additional arguments will not be
     *        mapped. If the method needs to accept unlimited arguments, use
     *        `defineInstanceWithArguments`. Otherwise if more options are
     *        required, use an options object instead.
     *
     * @example
     *
     *   Sugar.Number.defineInstance({
     *     square: function (num) {
     *       return num * num;
     *     }
     *   });
     *
     * @signature defineInstance(methodName, methodFn)
     * @param {Object} methods - Methods to be defined.
     * @param {string} methodName - Name of a single method to be defined.
     * @param {Function} methodFn - Function body of a single method to be defined.
     ***/
    defineWithOptionCollect('defineInstance', INSTANCE);

    /***
     * @method defineInstanceAndStatic(methods)
     * @returns SugarNamespace
     * @namespace SugarNamespace
     * @short A shortcut to define both static and instance methods on the namespace.
     * @extra This method is intended for use with `Object` instance methods. Sugar
     *        will not map any methods to `Object.prototype` by default, so defining
     *        instance methods as static helps facilitate their proper use.
     *
     * @example
     *
     *   Sugar.Object.defineInstanceAndStatic({
     *     isAwesome: function (obj) {
     *       // check if obj is awesome!
     *     }
     *   });
     *
     * @signature defineInstanceAndStatic(methodName, methodFn)
     * @param {Object} methods - Methods to be defined.
     * @param {string} methodName - Name of a single method to be defined.
     * @param {Function} methodFn - Function body of a single method to be defined.
     ***/
    defineWithOptionCollect('defineInstanceAndStatic', INSTANCE | STATIC);


    /***
     * @method defineStaticWithArguments(methods)
     * @returns SugarNamespace
     * @namespace SugarNamespace
     * @short Defines static methods that collect arguments.
     * @extra This method is identical to `defineStatic`, except that when defined
     *        methods are called, they will collect any arguments past `n - 1`,
     *        where `n` is the number of arguments that the method accepts.
     *        Collected arguments will be passed to the method in an array
     *        as the last argument defined on the function.
     *
     * @example
     *
     *   Sugar.Number.defineStaticWithArguments({
     *     addAll: function (num, args) {
     *       for (var i = 0; i < args.length; i++) {
     *         num += args[i];
     *       }
     *       return num;
     *     }
     *   });
     *
     * @signature defineStaticWithArguments(methodName, methodFn)
     * @param {Object} methods - Methods to be defined.
     * @param {string} methodName - Name of a single method to be defined.
     * @param {Function} methodFn - Function body of a single method to be defined.
     ***/
    defineWithOptionCollect('defineStaticWithArguments', STATIC, true);

    /***
     * @method defineInstanceWithArguments(methods)
     * @returns SugarNamespace
     * @namespace SugarNamespace
     * @short Defines instance methods that collect arguments.
     * @extra This method is identical to `defineInstance`, except that when
     *        defined methods are called, they will collect any arguments past
     *        `n - 1`, where `n` is the number of arguments that the method
     *        accepts. Collected arguments will be passed to the method as the
     *        last argument defined on the function.
     *
     * @example
     *
     *   Sugar.Number.defineInstanceWithArguments({
     *     addAll: function (num, args) {
     *       for (var i = 0; i < args.length; i++) {
     *         num += args[i];
     *       }
     *       return num;
     *     }
     *   });
     *
     * @signature defineInstanceWithArguments(methodName, methodFn)
     * @param {Object} methods - Methods to be defined.
     * @param {string} methodName - Name of a single method to be defined.
     * @param {Function} methodFn - Function body of a single method to be defined.
     ***/
    defineWithOptionCollect('defineInstanceWithArguments', INSTANCE, true);

    /***
     * @method defineStaticPolyfill(methods)
     * @returns SugarNamespace
     * @namespace SugarNamespace
     * @short Defines static methods that are mapped onto the native if they do
     *        not already exist.
     * @extra Intended only for use creating polyfills that follow the ECMAScript
     *        spec. Accepts either a single object mapping names to functions, or
     *        name and function as two arguments. Note that polyfill methods will
     *        be immediately mapped onto their native prototype regardless of the
     *        use of `extend`.
     *
     * @example
     *
     *   Sugar.Object.defineStaticPolyfill({
     *     keys: function (obj) {
     *       // get keys!
     *     }
     *   });
     *
     * @signature defineStaticPolyfill(methodName, methodFn)
     * @param {Object} methods - Methods to be defined.
     * @param {string} methodName - Name of a single method to be defined.
     * @param {Function} methodFn - Function body of a single method to be defined.
     ***/
    setProperty(sugarNamespace, 'defineStaticPolyfill', function(arg1, arg2, arg3) {
      var opts = collectDefineOptions(arg1, arg2, arg3);
      extendNative(globalContext[name], opts.methods, true, opts.last);
      return sugarNamespace;
    });

    /***
     * @method defineInstancePolyfill(methods)
     * @returns SugarNamespace
     * @namespace SugarNamespace
     * @short Defines instance methods that are mapped onto the native prototype
     *        if they do not already exist.
     * @extra Intended only for use creating polyfills that follow the ECMAScript
     *        spec. Accepts either a single object mapping names to functions, or
     *        name and function as two arguments. This method differs from
     *        `defineInstance` as there is no static signature (as the method
     *        is mapped as-is to the native), so it should refer to its `this`
     *        object. Note that polyfill methods will be immediately mapped onto
     *        their native prototype regardless of the use of `extend`.
     *
     * @example
     *
     *   Sugar.Array.defineInstancePolyfill({
     *     indexOf: function (arr, el) {
     *       // index finding code here!
     *     }
     *   });
     *
     * @signature defineInstancePolyfill(methodName, methodFn)
     * @param {Object} methods - Methods to be defined.
     * @param {string} methodName - Name of a single method to be defined.
     * @param {Function} methodFn - Function body of a single method to be defined.
     ***/
    setProperty(sugarNamespace, 'defineInstancePolyfill', function(arg1, arg2, arg3) {
      var opts = collectDefineOptions(arg1, arg2, arg3);
      extendNative(globalContext[name].prototype, opts.methods, true, opts.last);
      // Map instance polyfills to chainable as well.
      forEachProperty(opts.methods, function(fn, methodName) {
        defineChainableMethod(sugarNamespace, methodName, fn);
      });
      return sugarNamespace;
    });

    /***
     * @method alias(toName, from)
     * @returns SugarNamespace
     * @namespace SugarNamespace
     * @short Aliases one Sugar method to another.
     *
     * @example
     *
     *   Sugar.Array.alias('all', 'every');
     *
     * @signature alias(toName, fn)
     * @param {string} toName - Name for new method.
     * @param {string|Function} from - Method to alias, or string shortcut.
     ***/
    setProperty(sugarNamespace, 'alias', function(name, source) {
      var method = typeof source === 'string' ? sugarNamespace[source] : source;
      setMethod(sugarNamespace, name, method);
      return sugarNamespace;
    });

    // Each namespace can extend only itself through its .extend method.
    setProperty(sugarNamespace, 'extend', extend);

    // Cache the class to namespace relationship for later use.
    namespacesByName[name] = sugarNamespace;
    namespacesByClassString['[object ' + name + ']'] = sugarNamespace;

    mapNativeToChainable(name);
    mapObjectChainablesToNamespace(sugarNamespace);


    // Export
    return Sugar[name] = sugarNamespace;
  }

  function setGlobalProperties() {
    setProperty(Sugar, 'extend', Sugar);
    setProperty(Sugar, 'toString', toString);
    setProperty(Sugar, 'createNamespace', createNamespace);

    setProperty(Sugar, 'util', {
      'hasOwn': hasOwn,
      'getOwn': getOwn,
      'setProperty': setProperty,
      'classToString': classToString,
      'defineProperty': defineProperty,
      'forEachProperty': forEachProperty,
      'mapNativeToChainable': mapNativeToChainable
    });
  }

  function toString() {
    return SUGAR_GLOBAL;
  }


  // Defining Methods

  function defineMethods(sugarNamespace, methods, type, args, flags) {
    forEachProperty(methods, function(method, methodName) {
      var instanceMethod, staticMethod = method;
      if (args) {
        staticMethod = wrapMethodWithArguments(method);
      }
      if (flags) {
        staticMethod.flags = flags;
      }

      // A method may define its own custom implementation, so
      // make sure that's not the case before creating one.
      if (type & INSTANCE && !method.instance) {
        instanceMethod = wrapInstanceMethod(method, args);
        setProperty(staticMethod, 'instance', instanceMethod);
      }

      if (type & STATIC) {
        setProperty(staticMethod, 'static', true);
      }

      setMethod(sugarNamespace, methodName, staticMethod);

      if (sugarNamespace.active) {
        // If the namespace has been activated (.extend has been called),
        // then map this method as well.
        sugarNamespace.extend(methodName);
      }
    });
  }

  function collectDefineOptions(arg1, arg2, arg3) {
    var methods, last;
    if (typeof arg1 === 'string') {
      methods = {};
      methods[arg1] = arg2;
      last = arg3;
    } else {
      methods = arg1;
      last = arg2;
    }
    return {
      last: last,
      methods: methods
    };
  }

  function wrapInstanceMethod(fn, args) {
    return args ? wrapMethodWithArguments(fn, true) : wrapInstanceMethodFixed(fn);
  }

  function wrapMethodWithArguments(fn, instance) {
    // Functions accepting enumerated arguments will always have "args" as the
    // last argument, so subtract one from the function length to get the point
    // at which to start collecting arguments. If this is an instance method on
    // a prototype, then "this" will be pushed into the arguments array so start
    // collecting 1 argument earlier.
    var startCollect = fn.length - 1 - (instance ? 1 : 0);
    return function() {
      var args = [], collectedArgs = [], len;
      if (instance) {
        args.push(this);
      }
      len = Math.max(arguments.length, startCollect);
      // Optimized: no leaking arguments
      for (var i = 0; i < len; i++) {
        if (i < startCollect) {
          args.push(arguments[i]);
        } else {
          collectedArgs.push(arguments[i]);
        }
      }
      args.push(collectedArgs);
      return fn.apply(this, args);
    };
  }

  function wrapInstanceMethodFixed(fn) {
    switch(fn.length) {
      // Wrapped instance methods will always be passed the instance
      // as the first argument, but requiring the argument to be defined
      // may cause confusion here, so return the same wrapped function regardless.
      case 0:
      case 1:
        return function() {
          return fn(this);
        };
      case 2:
        return function(a) {
          return fn(this, a);
        };
      case 3:
        return function(a, b) {
          return fn(this, a, b);
        };
      case 4:
        return function(a, b, c) {
          return fn(this, a, b, c);
        };
      case 5:
        return function(a, b, c, d) {
          return fn(this, a, b, c, d);
        };
    }
  }

  // Method helpers

  function extendNative(target, source, polyfill, override) {
    forEachProperty(source, function(method, name) {
      if (polyfill && !override && target[name]) {
        // Method exists, so bail.
        return;
      }
      setProperty(target, name, method);
    });
  }

  function setMethod(sugarNamespace, methodName, method) {
    sugarNamespace[methodName] = method;
    if (method.instance) {
      defineChainableMethod(sugarNamespace, methodName, method.instance, true);
    }
  }


  // Chainables

  function getNewChainableClass(name) {
    var fn = function SugarChainable(obj, arg) {
      if (!(this instanceof fn)) {
        return new fn(obj, arg);
      }
      if (this.constructor !== fn) {
        // Allow modules to define their own constructors.
        obj = this.constructor.apply(obj, arguments);
      }
      this.raw = obj;
    };
    setProperty(fn, 'toString', function() {
      return SUGAR_GLOBAL + name;
    });
    setProperty(fn.prototype, 'valueOf', function() {
      return this.raw;
    });
    return fn;
  }

  function defineChainableMethod(sugarNamespace, methodName, fn) {
    var wrapped = wrapWithChainableResult(fn), existing, collision, dcp;
    dcp = DefaultChainable.prototype;
    existing = dcp[methodName];

    // If the method was previously defined on the default chainable, then a
    // collision exists, so set the method to a disambiguation function that will
    // lazily evaluate the object and find it's associated chainable. An extra
    // check is required to avoid false positives from Object inherited methods.
    collision = existing && existing !== Object.prototype[methodName];

    // The disambiguation function is only required once.
    if (!existing || !existing.disambiguate) {
      dcp[methodName] = collision ? disambiguateMethod(methodName) : wrapped;
    }

    // The target chainable always receives the wrapped method. Additionally,
    // if the target chainable is Sugar.Object, then map the wrapped method
    // to all other namespaces as well if they do not define their own method
    // of the same name. This way, a Sugar.Number will have methods like
    // isEqual that can be called on any object without having to traverse up
    // the prototype chain and perform disambiguation, which costs cycles.
    // Note that the "if" block below actually does nothing on init as Object
    // goes first and no other namespaces exist yet. However it needs to be
    // here as Object instance methods defined later also need to be mapped
    // back onto existing namespaces.
    sugarNamespace.prototype[methodName] = wrapped;
    if (sugarNamespace === Sugar.Object) {
      mapObjectChainableToAllNamespaces(methodName, wrapped);
    }
  }

  function mapObjectChainablesToNamespace(sugarNamespace) {
    forEachProperty(Sugar.Object && Sugar.Object.prototype, function(val, methodName) {
      if (typeof val === 'function') {
        setObjectChainableOnNamespace(sugarNamespace, methodName, val);
      }
    });
  }

  function mapObjectChainableToAllNamespaces(methodName, fn) {
    forEachProperty(namespacesByName, function(sugarNamespace) {
      setObjectChainableOnNamespace(sugarNamespace, methodName, fn);
    });
  }

  function setObjectChainableOnNamespace(sugarNamespace, methodName, fn) {
    var proto = sugarNamespace.prototype;
    if (!hasOwn(proto, methodName)) {
      proto[methodName] = fn;
    }
  }

  function wrapWithChainableResult(fn) {
    return function() {
      return new DefaultChainable(fn.apply(this.raw, arguments));
    };
  }

  function disambiguateMethod(methodName) {
    var fn = function() {
      var raw = this.raw, sugarNamespace;
      if (raw != null) {
        // Find the Sugar namespace for this unknown.
        sugarNamespace = namespacesByClassString[classToString(raw)];
      }
      if (!sugarNamespace) {
        // If no sugarNamespace can be resolved, then default
        // back to Sugar.Object so that undefined and other
        // non-supported types can still have basic object
        // methods called on them, such as type checks.
        sugarNamespace = Sugar.Object;
      }

      return new sugarNamespace(raw)[methodName].apply(this, arguments);
    };
    fn.disambiguate = true;
    return fn;
  }

  function mapNativeToChainable(name, methodNames) {
    var sugarNamespace = namespacesByName[name],
        nativeProto = globalContext[name].prototype;

    if (!methodNames && ownPropertyNames) {
      methodNames = ownPropertyNames(nativeProto);
    }

    forEachProperty(methodNames, function(methodName) {
      if (nativeMethodProhibited(methodName)) {
        // Sugar chainables have their own constructors as well as "valueOf"
        // methods, so exclude them here. The __proto__ argument should be trapped
        // by the function check below, however simply accessing this property on
        // Object.prototype causes QML to segfault, so pre-emptively excluding it.
        return;
      }
      try {
        var fn = nativeProto[methodName];
        if (typeof fn !== 'function') {
          // Bail on anything not a function.
          return;
        }
      } catch (e) {
        // Function.prototype has properties that
        // will throw errors when accessed.
        return;
      }
      defineChainableMethod(sugarNamespace, methodName, fn);
    });
  }

  function nativeMethodProhibited(methodName) {
    return methodName === 'constructor' ||
           methodName === 'valueOf' ||
           methodName === '__proto__';
  }


  // Util

  // Internal references
  var ownPropertyNames = Object.getOwnPropertyNames,
      internalToString = Object.prototype.toString,
      internalHasOwnProperty = Object.prototype.hasOwnProperty;

  // Defining this as a variable here as the ES5 module
  // overwrites it to patch DONTENUM.
  var forEachProperty = function (obj, fn) {
    for(var key in obj) {
      if (!hasOwn(obj, key)) continue;
      if (fn.call(obj, obj[key], key, obj) === false) break;
    }
  };

  // istanbul ignore next
  function definePropertyShim(obj, prop, descriptor) {
    obj[prop] = descriptor.value;
  }

  function setProperty(target, name, value, enumerable) {
    defineProperty(target, name, {
      value: value,
      enumerable: !!enumerable,
      configurable: true,
      writable: true
    });
  }

  // PERF: Attempts to speed this method up get very Heisenbergy. Quickly
  // returning based on typeof works for primitives, but slows down object
  // types. Even === checks on null and undefined (no typeof) will end up
  // basically breaking even. This seems to be as fast as it can go.
  function classToString(obj) {
    return internalToString.call(obj);
  }

  function hasOwn(obj, prop) {
    return !!obj && internalHasOwnProperty.call(obj, prop);
  }

  function getOwn(obj, prop) {
    if (hasOwn(obj, prop)) {
      return obj[prop];
    }
  }

  setupGlobal();

  /***
   * @module Common
   * @description Internal utility and common methods.
   ***/


  // Flag allowing native methods to be enhanced
  var ENHANCEMENTS_FLAG = 'enhance';

  // For type checking, etc. Excludes object as this is more nuanced.
  var NATIVE_TYPES = 'Boolean Number String Date RegExp Function Array Error Set Map';

  // Do strings have no keys?
  var NO_KEYS_IN_STRING_OBJECTS = !('0' in Object('a'));

  // Prefix for private properties
  var PRIVATE_PROP_PREFIX = '_sugar_';

  // Matches 1..2 style ranges in properties
  var PROPERTY_RANGE_REG = /^(.*?)\[([-\d]*)\.\.([-\d]*)\](.*)$/;

  // Regex for matching a formatted string
  var STRING_FORMAT_REG = /([{}])\1|\{([^}]*)\}|(%)%|(%(\w*))/g;

  // Common chars
  var HALF_WIDTH_ZERO = 0x30,
      FULL_WIDTH_ZERO = 0xff10,
      HALF_WIDTH_PERIOD   = '.',
      FULL_WIDTH_PERIOD   = '．',
      HALF_WIDTH_COMMA    = ',',
      OPEN_BRACE  = '{',
      CLOSE_BRACE = '}';

  // Namespace aliases
  var sugarObject   = Sugar.Object,
      sugarArray    = Sugar.Array,
      sugarDate     = Sugar.Date,
      sugarString   = Sugar.String,
      sugarNumber   = Sugar.Number,
      sugarFunction = Sugar.Function,
      sugarRegExp   = Sugar.RegExp;

  // Core utility aliases
  var hasOwn               = Sugar.util.hasOwn,
      getOwn               = Sugar.util.getOwn,
      setProperty          = Sugar.util.setProperty,
      classToString        = Sugar.util.classToString,
      defineProperty       = Sugar.util.defineProperty,
      forEachProperty      = Sugar.util.forEachProperty,
      mapNativeToChainable = Sugar.util.mapNativeToChainable;

  // Class checks
  var isSerializable,
      isBoolean, isNumber, isString,
      isDate, isRegExp, isFunction,
      isArray, isSet, isMap, isError;

  function buildClassChecks() {

    var knownTypes = {};

    function addCoreTypes() {

      var names = spaceSplit(NATIVE_TYPES);

      isBoolean = buildPrimitiveClassCheck(names[0]);
      isNumber  = buildPrimitiveClassCheck(names[1]);
      isString  = buildPrimitiveClassCheck(names[2]);

      isDate   = buildClassCheck(names[3]);
      isRegExp = buildClassCheck(names[4]);

      // Wanted to enhance performance here by using simply "typeof"
      // but Firefox has two major issues that make this impossible,
      // one fixed, the other not, so perform a full class check here.
      //
      // 1. Regexes can be typeof "function" in FF < 3
      //    https://bugzilla.mozilla.org/show_bug.cgi?id=61911 (fixed)
      //
      // 2. HTMLEmbedElement and HTMLObjectElement are be typeof "function"
      //    https://bugzilla.mozilla.org/show_bug.cgi?id=268945 (won't fix)
      isFunction = buildClassCheck(names[5]);


      isArray = Array.isArray || buildClassCheck(names[6]);
      isError = buildClassCheck(names[7]);

      isSet = buildClassCheck(names[8], typeof Set !== 'undefined' && Set);
      isMap = buildClassCheck(names[9], typeof Map !== 'undefined' && Map);

      // Add core types as known so that they can be checked by value below,
      // notably excluding Functions and adding Arguments and Error.
      addKnownType('Arguments');
      addKnownType(names[0]);
      addKnownType(names[1]);
      addKnownType(names[2]);
      addKnownType(names[3]);
      addKnownType(names[4]);
      addKnownType(names[6]);

    }

    function addArrayTypes() {
      var types = 'Int8 Uint8 Uint8Clamped Int16 Uint16 Int32 Uint32 Float32 Float64';
      forEach(spaceSplit(types), function(str) {
        addKnownType(str + 'Array');
      });
    }

    function addKnownType(className) {
      var str = '[object '+ className +']';
      knownTypes[str] = true;
    }

    function isKnownType(className) {
      return knownTypes[className];
    }

    function buildClassCheck(className, globalObject) {
      // istanbul ignore if
      if (globalObject && isClass(new globalObject, 'Object')) {
        return getConstructorClassCheck(globalObject);
      } else {
        return getToStringClassCheck(className);
      }
    }

    // Map and Set may be [object Object] in certain IE environments.
    // In this case we need to perform a check using the constructor
    // instead of Object.prototype.toString.
    // istanbul ignore next
    function getConstructorClassCheck(obj) {
      var ctorStr = String(obj);
      return function(obj) {
        return String(obj.constructor) === ctorStr;
      };
    }

    function getToStringClassCheck(className) {
      return function(obj, str) {
        // perf: Returning up front on instanceof appears to be slower.
        return isClass(obj, className, str);
      };
    }

    function buildPrimitiveClassCheck(className) {
      var type = className.toLowerCase();
      return function(obj) {
        var t = typeof obj;
        return t === type || t === 'object' && isClass(obj, className);
      };
    }

    addCoreTypes();
    addArrayTypes();

    isSerializable = function(obj, className) {
      // Only known objects can be serialized. This notably excludes functions,
      // host objects, Symbols (which are matched by reference), and instances
      // of classes. The latter can arguably be matched by value, but
      // distinguishing between these and host objects -- which should never be
      // compared by value -- is very tricky so not dealing with it here.
      className = className || classToString(obj);
      return isKnownType(className) || isPlainObject(obj, className);
    };

  }

  function isClass(obj, className, str) {
    if (!str) {
      str = classToString(obj);
    }
    return str === '[object '+ className +']';
  }

  // Wrapping the core's "define" methods to
  // save a few bytes in the minified script.
  function wrapNamespace(method) {
    return function(sugarNamespace, arg1, arg2) {
      sugarNamespace[method](arg1, arg2);
    };
  }

  // Method define aliases
  var alias                       = wrapNamespace('alias'),
      defineStatic                = wrapNamespace('defineStatic'),
      defineInstance              = wrapNamespace('defineInstance'),
      defineStaticPolyfill        = wrapNamespace('defineStaticPolyfill'),
      defineInstancePolyfill      = wrapNamespace('defineInstancePolyfill'),
      defineInstanceAndStatic     = wrapNamespace('defineInstanceAndStatic'),
      defineInstanceWithArguments = wrapNamespace('defineInstanceWithArguments');

  function defineInstanceAndStaticSimilar(sugarNamespace, set, fn, flags) {
    defineInstanceAndStatic(sugarNamespace, collectSimilarMethods(set, fn), flags);
  }

  function collectSimilarMethods(set, fn) {
    var methods = {};
    if (isString(set)) {
      set = spaceSplit(set);
    }
    forEach(set, function(el, i) {
      fn(methods, el, i);
    });
    return methods;
  }

  // This song and dance is to fix methods to a different length
  // from what they actually accept in order to stay in line with
  // spec. Additionally passing argument length, as some methods
  // throw assertion errors based on this (undefined check is not
  // enough). Fortunately for now spec is such that passing 3
  // actual arguments covers all requirements. Note that passing
  // the argument length also forces the compiler to not rewrite
  // length of the compiled function.
  function fixArgumentLength(fn) {
    var staticFn = function(a) {
      var args = arguments;
      return fn(a, args[1], args[2], args.length - 1);
    };
    staticFn.instance = function(b) {
      var args = arguments;
      return fn(this, b, args[1], args.length);
    };
    return staticFn;
  }

  function defineAccessor(namespace, name, fn) {
    setProperty(namespace, name, fn);
  }

  function defineOptionsAccessor(namespace, defaults) {
    var obj = simpleClone(defaults);

    function getOption(name) {
      return obj[name];
    }

    function setOption(arg1, arg2) {
      var options;
      if (arguments.length === 1) {
        options = arg1;
      } else {
        options = {};
        options[arg1] = arg2;
      }
      forEachProperty(options, function(val, name) {
        if (val === null) {
          val = defaults[name];
        }
        obj[name] = val;
      });
    }

    defineAccessor(namespace, 'getOption', getOption);
    defineAccessor(namespace, 'setOption', setOption);
    return getOption;
  }

  function assertArgument(exists) {
    if (!exists) {
      throw new TypeError('Argument required');
    }
  }

  function assertCallable(obj) {
    if (!isFunction(obj)) {
      throw new TypeError('Function is not callable');
    }
  }

  function assertArray(obj) {
    if (!isArray(obj)) {
      throw new TypeError('Array required');
    }
  }

  function assertWritable(obj) {
    if (isPrimitive(obj)) {
      // If strict mode is active then primitives will throw an
      // error when attempting to write properties. We can't be
      // sure if strict mode is available, so pre-emptively
      // throw an error here to ensure consistent behavior.
      throw new TypeError('Property cannot be written');
    }
  }

  // Coerces an object to a positive integer.
  // Does not allow Infinity.
  function coercePositiveInteger(n) {
    n = +n || 0;
    if (n < 0 || !isNumber(n) || !isFinite(n)) {
      throw new RangeError('Invalid number');
    }
    return trunc(n);
  }

  function isDefined(o) {
    return o !== undefined;
  }

  function isUndefined(o) {
    return o === undefined;
  }

  function privatePropertyAccessor(key) {
    var privateKey = PRIVATE_PROP_PREFIX + key;
    return function(obj, val) {
      if (arguments.length > 1) {
        setProperty(obj, privateKey, val);
        return obj;
      }
      return obj[privateKey];
    };
  }

  function setChainableConstructor(sugarNamespace, createFn) {
    sugarNamespace.prototype.constructor = function() {
      return createFn.apply(this, arguments);
    };
  }

  function getMatcher(f) {
    if (!isPrimitive(f)) {
      var className = classToString(f);
      if (isRegExp(f, className)) {
        return regexMatcher(f);
      } else if (isDate(f, className)) {
        return dateMatcher(f);
      } else if (isFunction(f, className)) {
        return functionMatcher(f);
      } else if (isPlainObject(f, className)) {
        return fuzzyMatcher(f);
      }
    }
    // Default is standard isEqual
    return defaultMatcher(f);
  }

  function fuzzyMatcher(obj) {
    var matchers = {};
    return function(el, i, arr) {
      var matched = true;
      if (!isObjectType(el)) {
        return false;
      }
      forEachProperty(obj, function(val, key) {
        matchers[key] = getOwn(matchers, key) || getMatcher(val);
        if (matchers[key].call(arr, el[key], i, arr) === false) {
          matched = false;
        }
        return matched;
      });
      return matched;
    };
  }

  function defaultMatcher(f) {
    return function(el) {
      return isEqual(el, f);
    };
  }

  function regexMatcher(reg) {
    reg = RegExp(reg);
    return function(el) {
      return reg.test(el);
    };
  }

  function dateMatcher(d) {
    var ms = d.getTime();
    return function(el) {
      return !!(el && el.getTime) && el.getTime() === ms;
    };
  }

  function functionMatcher(fn) {
    return function(el, i, arr) {
      // Return true up front if match by reference
      return el === fn || fn.call(arr, el, i, arr);
    };
  }

  function getKeys(obj) {
    return Object.keys(obj);
  }

  function deepGetProperty(obj, key, any) {
    return handleDeepProperty(obj, key, any, false);
  }

  function handleDeepProperty(obj, key, any, has, fill, fillLast, val) {
    var ns, bs, ps, cbi, set, isLast, isPush, isIndex, nextIsIndex, exists;
    ns = obj || undefined;
    if (key == null) return;

    if (isObjectType(key)) {
      // Allow array and array-like accessors
      bs = [key];
    } else {
      key = String(key);
      if (key.indexOf('..') !== -1) {
        return handleArrayIndexRange(obj, key, any, val);
      }
      bs = key.split('[');
    }

    set = isDefined(val);

    for (var i = 0, blen = bs.length; i < blen; i++) {
      ps = bs[i];

      if (isString(ps)) {
        ps = periodSplit(ps);
      }

      for (var j = 0, plen = ps.length; j < plen; j++) {
        key = ps[j];

        // Is this the last key?
        isLast = i === blen - 1 && j === plen - 1;

        // Index of the closing ]
        cbi = key.indexOf(']');

        // Is the key an array index?
        isIndex = cbi !== -1;

        // Is this array push syntax "[]"?
        isPush = set && cbi === 0;

        // If the bracket split was successful and this is the last element
        // in the dot split, then we know the next key will be an array index.
        nextIsIndex = blen > 1 && j === plen - 1;

        if (isPush) {
          // Set the index to the end of the array
          key = ns.length;
        } else if (isIndex) {
          // Remove the closing ]
          key = key.slice(0, -1);
        }

        // If the array index is less than 0, then
        // add its length to allow negative indexes.
        if (isIndex && key < 0) {
          key = +key + ns.length;
        }

        // Bracket keys may look like users[5] or just [5], so the leading
        // characters are optional. We can enter the namespace if this is the
        // 2nd part, if there is only 1 part, or if there is an explicit key.
        if (i || key || blen === 1) {

          exists = any ? key in ns : hasOwn(ns, key);

          // Non-existent namespaces are only filled if they are intermediate
          // (not at the end) or explicitly filling the last.
          if (fill && (!isLast || fillLast) && !exists) {
            // For our purposes, last only needs to be an array.
            ns = ns[key] = nextIsIndex || (fillLast && isLast) ? [] : {};
            continue;
          }

          if (has) {
            if (isLast || !exists) {
              return exists;
            }
          } else if (set && isLast) {
            assertWritable(ns);
            ns[key] = val;
          }

          ns = exists ? ns[key] : undefined;
        }

      }
    }
    return ns;
  }

  // Get object property with support for 0..1 style range notation.
  function handleArrayIndexRange(obj, key, any, val) {
    var match, start, end, leading, trailing, arr, set;
    match = key.match(PROPERTY_RANGE_REG);
    if (!match) {
      return;
    }

    set = isDefined(val);
    leading = match[1];

    if (leading) {
      arr = handleDeepProperty(obj, leading, any, false, set ? true : false, true);
    } else {
      arr = obj;
    }

    assertArray(arr);

    trailing = match[4];
    start    = match[2] ? +match[2] : 0;
    end      = match[3] ? +match[3] : arr.length;

    // A range of 0..1 is inclusive, so we need to add 1 to the end. If this
    // pushes the index from -1 to 0, then set it to the full length of the
    // array, otherwise it will return nothing.
    end = end === -1 ? arr.length : end + 1;

    if (set) {
      for (var i = start; i < end; i++) {
        handleDeepProperty(arr, i + trailing, any, false, true, false, val);
      }
    } else {
      arr = arr.slice(start, end);

      // If there are trailing properties, then they need to be mapped for each
      // element in the array.
      if (trailing) {
        if (trailing.charAt(0) === HALF_WIDTH_PERIOD) {
          // Need to chomp the period if one is trailing after the range. We
          // can't do this at the regex level because it will be required if
          // we're setting the value as it needs to be concatentated together
          // with the array index to be set.
          trailing = trailing.slice(1);
        }
        return arr.map(function(el) {
          return handleDeepProperty(el, trailing);
        });
      }
    }
    return arr;
  }

  function isObjectType(obj, type) {
    return !!obj && (type || typeof obj) === 'object';
  }

  function isPrimitive(obj, type) {
    type = type || typeof obj;
    return obj == null || type === 'string' || type === 'number' || type === 'boolean';
  }

  function isPlainObject(obj, className) {
    return isObjectType(obj) &&
           isClass(obj, 'Object', className) &&
           hasValidPlainObjectPrototype(obj) &&
           hasOwnEnumeratedProperties(obj);
  }

  function hasValidPlainObjectPrototype(obj) {
    var hasToString = 'toString' in obj;
    var hasConstructor = 'constructor' in obj;
    // An object created with Object.create(null) has no methods in the
    // prototype chain, so check if any are missing. The additional hasToString
    // check is for false positives on some host objects in old IE which have
    // toString but no constructor. If the object has an inherited constructor,
    // then check if it is Object (the "isPrototypeOf" tapdance here is a more
    // robust way of ensuring this if the global has been hijacked). Note that
    // accessing the constructor directly (without "in" or "hasOwnProperty")
    // will throw a permissions error in IE8 on cross-domain windows.
    return (!hasConstructor && !hasToString) ||
            (hasConstructor && !hasOwn(obj, 'constructor') &&
             hasOwn(obj.constructor.prototype, 'isPrototypeOf'));
  }

  function hasOwnEnumeratedProperties(obj) {
    // Plain objects are generally defined as having enumerated properties
    // all their own, however in early IE environments without defineProperty,
    // there may also be enumerated methods in the prototype chain, so check
    // for both of these cases.
    var objectProto = Object.prototype;
    for (var key in obj) {
      var val = obj[key];
      if (!hasOwn(obj, key) && val !== objectProto[key]) {
        return false;
      }
    }
    return true;
  }

  function simpleRepeat(n, fn) {
    for (var i = 0; i < n; i++) {
      fn(i);
    }
  }

  function simpleClone(obj) {
    return simpleMerge({}, obj);
  }

  function simpleMerge(target, source) {
    forEachProperty(source, function(val, key) {
      target[key] = val;
    });
    return target;
  }

  // Make primtives types like strings into objects.
  function coercePrimitiveToObject(obj) {
    if (isPrimitive(obj)) {
      obj = Object(obj);
    }
    // istanbul ignore if
    if (NO_KEYS_IN_STRING_OBJECTS && isString(obj)) {
      forceStringCoercion(obj);
    }
    return obj;
  }

  // Force strings to have their indexes set in
  // environments that don't do this automatically.
  // istanbul ignore next
  function forceStringCoercion(obj) {
    var i = 0, chr;
    while (chr = obj.charAt(i)) {
      obj[i++] = chr;
    }
  }

  // Perf
  function isEqual(a, b, stack) {
    var aClass, bClass;
    if (a === b) {
      // Return quickly up front when matched by reference,
      // but be careful about 0 !== -0.
      return a !== 0 || 1 / a === 1 / b;
    }
    aClass = classToString(a);
    bClass = classToString(b);
    if (aClass !== bClass) {
      return false;
    }

    if (isSerializable(a, aClass) && isSerializable(b, bClass)) {
      return objectIsEqual(a, b, aClass, stack);
    } else if (isSet(a, aClass) && isSet(b, bClass)) {
      return a.size === b.size && isEqual(setToArray(a), setToArray(b), stack);
    } else if (isMap(a, aClass) && isMap(b, bClass)) {
      return a.size === b.size && isEqual(mapToArray(a), mapToArray(b), stack);
    } else if (isError(a, aClass) && isError(b, bClass)) {
      return a.toString() === b.toString();
    }

    return false;
  }

  // Perf
  function objectIsEqual(a, b, aClass, stack) {
    var aType = typeof a, bType = typeof b, propsEqual, count;
    if (aType !== bType) {
      return false;
    }
    if (isObjectType(a.valueOf())) {
      if (a.length !== b.length) {
        // perf: Quickly returning up front for arrays.
        return false;
      }
      count = 0;
      propsEqual = true;
      iterateWithCyclicCheck(a, false, stack, function(key, val, cyc, stack) {
        if (!cyc && (!(key in b) || !isEqual(val, b[key], stack))) {
          propsEqual = false;
        }
        count++;
        return propsEqual;
      });
      if (!propsEqual || count !== getKeys(b).length) {
        return false;
      }
    }
    // Stringifying the value handles NaN, wrapped primitives, dates, and errors in one go.
    return a.valueOf().toString() === b.valueOf().toString();
  }

  // Serializes an object in a way that will provide a token unique
  // to the type, class, and value of an object. Host objects, class
  // instances etc, are not serializable, and are held in an array
  // of references that will return the index as a unique identifier
  // for the object. This array is passed from outside so that the
  // calling function can decide when to dispose of this array.
  function serializeInternal(obj, refs, stack) {
    var type = typeof obj, className, value, ref;

    // Return quickly for primitives to save cycles
    if (isPrimitive(obj, type) && !isRealNaN(obj)) {
      return type + obj;
    }

    className = classToString(obj);

    if (!isSerializable(obj, className)) {
      ref = indexOf(refs, obj);
      if (ref === -1) {
        ref = refs.length;
        refs.push(obj);
      }
      return ref;
    } else if (isObjectType(obj)) {
      value = serializeDeep(obj, refs, stack) + obj.toString();
    } else if (1 / obj === -Infinity) {
      value = '-0';
    } else if (obj.valueOf) {
      value = obj.valueOf();
    }
    return type + className + value;
  }

  function serializeDeep(obj, refs, stack) {
    var result = '';
    iterateWithCyclicCheck(obj, true, stack, function(key, val, cyc, stack) {
      result += cyc ? 'CYC' : key + serializeInternal(val, refs, stack);
    });
    return result;
  }

  function iterateWithCyclicCheck(obj, sortedKeys, stack, fn) {

    function next(val, key) {
      var cyc = false;

      // Allowing a step into the structure before triggering this check to save
      // cycles on standard JSON structures and also to try as hard as possible to
      // catch basic properties that may have been modified.
      if (stack.length > 1) {
        var i = stack.length;
        while (i--) {
          if (stack[i] === val) {
            cyc = true;
          }
        }
      }

      stack.push(val);
      fn(key, val, cyc, stack);
      stack.pop();
    }

    function iterateWithSortedKeys() {
      // Sorted keys is required for serialization, where object order
      // does not matter but stringified order does.
      var arr = getKeys(obj).sort(), key;
      for (var i = 0; i < arr.length; i++) {
        key = arr[i];
        next(obj[key], arr[i]);
      }
    }

    // This method for checking for cyclic structures was egregiously stolen from
    // the ingenious method by @kitcambridge from the Underscore script:
    // https://github.com/documentcloud/underscore/issues/240
    if (!stack) {
      stack = [];
    }

    if (sortedKeys) {
      iterateWithSortedKeys();
    } else {
      forEachProperty(obj, next);
    }
  }

  function isArrayIndex(n) {
    return n >>> 0 == n && n != 0xFFFFFFFF;
  }

  function iterateOverSparseArray(arr, fn, fromIndex, loop) {
    var indexes = getSparseArrayIndexes(arr, fromIndex, loop), index;
    for (var i = 0, len = indexes.length; i < len; i++) {
      index = indexes[i];
      fn.call(arr, arr[index], index, arr);
    }
    return arr;
  }

  // It's unclear whether or not sparse arrays qualify as "simple enumerables".
  // If they are not, however, the wrapping function will be deoptimized, so
  // isolate here (also to share between es5 and array modules).
  function getSparseArrayIndexes(arr, fromIndex, loop, fromRight) {
    var indexes = [], i;
    for (i in arr) {
      if (isArrayIndex(i) && (loop || (fromRight ? i <= fromIndex : i >= fromIndex))) {
        indexes.push(+i);
      }
    }
    indexes.sort(function(a, b) {
      var aLoop = a > fromIndex;
      var bLoop = b > fromIndex;
      // This block cannot be reached unless ES5 methods are being shimmed.
      // istanbul ignore if
      if (aLoop !== bLoop) {
        return aLoop ? -1 : 1;
      }
      return a - b;
    });
    return indexes;
  }

  function getEntriesForIndexes(obj, find, loop, isString) {
    var result, length = obj.length;
    if (!isArray(find)) {
      return entryAtIndex(obj, find, length, loop, isString);
    }
    result = new Array(find.length);
    forEach(find, function(index, i) {
      result[i] = entryAtIndex(obj, index, length, loop, isString);
    });
    return result;
  }

  function getNormalizedIndex(index, length, loop) {
    if (index && loop) {
      index = index % length;
    }
    if (index < 0) index = length + index;
    return index;
  }

  function entryAtIndex(obj, index, length, loop, isString) {
    index = getNormalizedIndex(index, length, loop);
    return isString ? obj.charAt(index) : obj[index];
  }

  function mapWithShortcuts(el, f, context, mapArgs) {
    if (!f) {
      return el;
    } else if (f.apply) {
      return f.apply(context, mapArgs || []);
    } else if (isArray(f)) {
      return f.map(function(m) {
        return mapWithShortcuts(el, m, context, mapArgs);
      });
    } else if (isFunction(el[f])) {
      return el[f].call(el);
    } else {
      return deepGetProperty(el, f);
    }
  }

  function spaceSplit(str) {
    return str.split(' ');
  }

  function periodSplit(str) {
    return str.split(HALF_WIDTH_PERIOD);
  }

  function forEach(arr, fn) {
    for (var i = 0, len = arr.length; i < len; i++) {
      if (!(i in arr)) {
        return iterateOverSparseArray(arr, fn, i);
      }
      fn(arr[i], i);
    }
  }

  function filter(arr, fn) {
    var result = [];
    for (var i = 0, len = arr.length; i < len; i++) {
      var el = arr[i];
      if (i in arr && fn(el, i)) {
        result.push(el);
      }
    }
    return result;
  }

  function map(arr, fn) {
    // perf: Not using fixed array len here as it may be sparse.
    var result = [];
    for (var i = 0, len = arr.length; i < len; i++) {
      if (i in arr) {
        result.push(fn(arr[i], i));
      }
    }
    return result;
  }

  function indexOf(arr, el) {
    for (var i = 0, len = arr.length; i < len; i++) {
      if (i in arr && arr[i] === el) return i;
    }
    return -1;
  }

  // istanbul ignore next
  var trunc = Math.trunc || function(n) {
    if (n === 0 || !isFinite(n)) return n;
    return n < 0 ? ceil(n) : floor(n);
  };

  function isRealNaN(obj) {
    // This is only true of NaN
    return obj != null && obj !== obj;
  }

  function withPrecision(val, precision, fn) {
    var multiplier = pow(10, abs(precision || 0));
    fn = fn || round;
    if (precision < 0) multiplier = 1 / multiplier;
    return fn(val * multiplier) / multiplier;
  }

  // Fullwidth number helpers
  var fullWidthNumberReg, fullWidthNumberMap, fullWidthNumbers;

  function buildFullWidthNumber() {
    var fwp = FULL_WIDTH_PERIOD, hwp = HALF_WIDTH_PERIOD, hwc = HALF_WIDTH_COMMA, fwn = '';
    fullWidthNumberMap = {};
    for (var i = 0, digit; i <= 9; i++) {
      digit = chr(i + FULL_WIDTH_ZERO);
      fwn += digit;
      fullWidthNumberMap[digit] = chr(i + HALF_WIDTH_ZERO);
    }
    fullWidthNumberMap[hwc] = '';
    fullWidthNumberMap[fwp] = hwp;
    // Mapping this to itself to capture it easily
    // in stringToNumber to detect decimals later.
    fullWidthNumberMap[hwp] = hwp;
    fullWidthNumberReg = allCharsReg(fwn + fwp + hwc + hwp);
    fullWidthNumbers = fwn;
  }

  // Takes into account full-width characters, commas, and decimals.
  function stringToNumber(str, base) {
    var sanitized, isDecimal;
    sanitized = str.replace(fullWidthNumberReg, function(chr) {
      var replacement = getOwn(fullWidthNumberMap, chr);
      if (replacement === HALF_WIDTH_PERIOD) {
        isDecimal = true;
      }
      return replacement;
    });
    return isDecimal ? parseFloat(sanitized) : parseInt(sanitized, base || 10);
  }

  // Math aliases
  var abs   = Math.abs,
      pow   = Math.pow,
      min   = Math.min,
      max   = Math.max,
      ceil  = Math.ceil,
      floor = Math.floor,
      round = Math.round;

  var chr = String.fromCharCode;

  function trim(str) {
    return str.trim();
  }

  function repeatString(str, num) {
    var result = '';
    str = str.toString();
    while (num > 0) {
      if (num & 1) {
        result += str;
      }
      if (num >>= 1) {
        str += str;
      }
    }
    return result;
  }

  function simpleCapitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  function createFormatMatcher(bracketMatcher, percentMatcher, precheck) {

    var reg = STRING_FORMAT_REG;
    var compileMemoized = memoizeFunction(compile);

    function getToken(format, match) {
      var get, token, literal, fn;
      var bKey = match[2];
      var pLit = match[3];
      var pKey = match[5];
      if (match[4] && percentMatcher) {
        token = pKey;
        get = percentMatcher;
      } else if (bKey) {
        token = bKey;
        get = bracketMatcher;
      } else if (pLit && percentMatcher) {
        literal = pLit;
      } else {
        literal = match[1] || match[0];
      }
      if (get) {
        assertPassesPrecheck(precheck, bKey, pKey);
        fn = function(obj, opt) {
          return get(obj, token, opt);
        };
      }
      format.push(fn || getLiteral(literal));
    }

    function getSubstring(format, str, start, end) {
      if (end > start) {
        var sub = str.slice(start, end);
        assertNoUnmatched(sub, OPEN_BRACE);
        assertNoUnmatched(sub, CLOSE_BRACE);
        format.push(function() {
          return sub;
        });
      }
    }

    function getLiteral(str) {
      return function() {
        return str;
      };
    }

    function assertPassesPrecheck(precheck, bt, pt) {
      if (precheck && !precheck(bt, pt)) {
        throw new TypeError('Invalid token '+ (bt || pt) +' in format string');
      }
    }

    function assertNoUnmatched(str, chr) {
      if (str.indexOf(chr) !== -1) {
        throw new TypeError('Unmatched '+ chr +' in format string');
      }
    }

    function compile(str) {
      var format = [], lastIndex = 0, match;
      reg.lastIndex = 0;
      while(match = reg.exec(str)) {
        getSubstring(format, str, lastIndex, match.index);
        getToken(format, match);
        lastIndex = reg.lastIndex;
      }
      getSubstring(format, str, lastIndex, str.length);
      return format;
    }

    return function(str, obj, opt) {
      var format = compileMemoized(str), result = '';
      for (var i = 0; i < format.length; i++) {
        result += format[i](obj, opt);
      }
      return result;
    };
  }

  var Inflections = {};

  function getAcronym(str) {
    return Inflections.acronyms && Inflections.acronyms.find(str);
  }

  function allCharsReg(src) {
    return RegExp('[' + src + ']', 'g');
  }

  function getRegExpFlags(reg, add) {
    var flags = '';
    add = add || '';
    function checkFlag(prop, flag) {
      if (prop || add.indexOf(flag) > -1) {
        flags += flag;
      }
    }
    checkFlag(reg.global, 'g');
    checkFlag(reg.ignoreCase, 'i');
    checkFlag(reg.multiline, 'm');
    checkFlag(reg.sticky, 'y');
    return flags;
  }

  function escapeRegExp(str) {
    if (!isString(str)) str = String(str);
    return str.replace(/([\\\/\'*+?|()\[\]{}.^$-])/g,'\\$1');
  }

  var INTERNAL_MEMOIZE_LIMIT = 1000;

  // Note that attemps to consolidate this with Function#memoize
  // ended up clunky as that is also serializing arguments. Separating
  // these implementations turned out to be simpler.
  function memoizeFunction(fn) {
    var memo = {}, counter = 0;

    return function(key) {
      if (hasOwn(memo, key)) {
        return memo[key];
      }
      // istanbul ignore if
      if (counter === INTERNAL_MEMOIZE_LIMIT) {
        memo = {};
        counter = 0;
      }
      counter++;
      return memo[key] = fn(key);
    };
  }

  function setToArray(set) {
    var arr = new Array(set.size), i = 0;
    set.forEach(function(val) {
      arr[i++] = val;
    });
    return arr;
  }

  function mapToArray(map) {
    var arr = new Array(map.size), i = 0;
    map.forEach(function(val, key) {
      arr[i++] = [key, val];
    });
    return arr;
  }

  buildClassChecks();

  buildFullWidthNumber();

  /***
   * @module Inflections
   * @namespace String
   * @description Pluralization and support for acronyms and humanized strings in
   *              string inflecting methods.
   *
   ***/


  var InflectionSet;

  function buildInflectionSet() {

    InflectionSet = function() {
      this.map = {};
      this.rules = [];
    };

    InflectionSet.prototype = {

      add: function(rule, replacement) {
        if (isString(rule)) {
          this.map[rule] = replacement;
        } else {
          this.rules.unshift({
            rule: rule,
            replacement: replacement
          });
        }
      },

      inflect: function(str) {
        var arr, idx, word;

        arr = str.split(' ');
        idx = arr.length - 1;
        word = arr[idx];

        arr[idx] = this.find(word) || this.runRules(word);
        return arr.join(' ');
      },

      find: function(str) {
        return getOwn(this.map, str);
      },

      runRules: function(str) {
        for (var i = 0, r; r = this.rules[i]; i++) {
          if (r.rule.test(str)) {
            str = str.replace(r.rule, r.replacement);
            break;
          }
        }
        return str;
      }

    };

  }

  // Global inflection runners. Allowing the build functions below to define
  // these functions so that common inflections will also be bundled together
  // when these methods are modularized.
  var inflectPlurals;

  function buildCommonPlurals() {

    inflectPlurals = function(type, str) {
      return Inflections[type] && Inflections[type].inflect(str) || str;
    };

    addPlural(/$/, 's');
    addPlural(/s$/i, 's');
    addPlural(/(ax|test)is$/i, '$1es');
    addPlural(/(octop|fung|foc|radi|alumn|cact)(i|us)$/i, '$1i');
    addPlural(/(census|alias|status|fetus|genius|virus)$/i, '$1es');
    addPlural(/(bu)s$/i, '$1ses');
    addPlural(/(buffal|tomat)o$/i, '$1oes');
    addPlural(/([ti])um$/i, '$1a');
    addPlural(/([ti])a$/i, '$1a');
    addPlural(/sis$/i, 'ses');
    addPlural(/f+e?$/i, 'ves');
    addPlural(/(cuff|roof)$/i, '$1s');
    addPlural(/([ht]ive)$/i, '$1s');
    addPlural(/([^aeiouy]o)$/i, '$1es');
    addPlural(/([^aeiouy]|qu)y$/i, '$1ies');
    addPlural(/(x|ch|ss|sh)$/i, '$1es');
    addPlural(/(tr|vert)(?:ix|ex)$/i, '$1ices');
    addPlural(/([ml])ouse$/i, '$1ice');
    addPlural(/([ml])ice$/i, '$1ice');
    addPlural(/^(ox)$/i, '$1en');
    addPlural(/^(oxen)$/i, '$1');
    addPlural(/(quiz)$/i, '$1zes');
    addPlural(/(phot|cant|hom|zer|pian|portic|pr|quart|kimon)o$/i, '$1os');
    addPlural(/(craft)$/i, '$1');
    addPlural(/([ft])[eo]{2}(th?)$/i, '$1ee$2');

    addSingular(/s$/i, '');
    addSingular(/([pst][aiu]s)$/i, '$1');
    addSingular(/([aeiouy])ss$/i, '$1ss');
    addSingular(/(n)ews$/i, '$1ews');
    addSingular(/([ti])a$/i, '$1um');
    addSingular(/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, '$1$2sis');
    addSingular(/(^analy)ses$/i, '$1sis');
    addSingular(/(i)(f|ves)$/i, '$1fe');
    addSingular(/([aeolr]f?)(f|ves)$/i, '$1f');
    addSingular(/([ht]ive)s$/i, '$1');
    addSingular(/([^aeiouy]|qu)ies$/i, '$1y');
    addSingular(/(s)eries$/i, '$1eries');
    addSingular(/(m)ovies$/i, '$1ovie');
    addSingular(/(x|ch|ss|sh)es$/i, '$1');
    addSingular(/([ml])(ous|ic)e$/i, '$1ouse');
    addSingular(/(bus)(es)?$/i, '$1');
    addSingular(/(o)es$/i, '$1');
    addSingular(/(shoe)s?$/i, '$1');
    addSingular(/(cris|ax|test)[ie]s$/i, '$1is');
    addSingular(/(octop|fung|foc|radi|alumn|cact)(i|us)$/i, '$1us');
    addSingular(/(census|alias|status|fetus|genius|virus)(es)?$/i, '$1');
    addSingular(/^(ox)(en)?/i, '$1');
    addSingular(/(vert)(ex|ices)$/i, '$1ex');
    addSingular(/tr(ix|ices)$/i, 'trix');
    addSingular(/(quiz)(zes)?$/i, '$1');
    addSingular(/(database)s?$/i, '$1');
    addSingular(/ee(th?)$/i, 'oo$1');

    addIrregular('person', 'people');
    addIrregular('man', 'men');
    addIrregular('human', 'humans');
    addIrregular('child', 'children');
    addIrregular('sex', 'sexes');
    addIrregular('move', 'moves');
    addIrregular('save', 'saves');
    addIrregular('goose', 'geese');
    addIrregular('zombie', 'zombies');

    addUncountable('equipment information rice money species series fish deer sheep jeans');

  }

  function addPlural(singular, plural) {
    plural = plural || singular;
    addInflection('plural', singular, plural);
    if (isString(singular)) {
      addSingular(plural, singular);
    }
  }

  function addSingular(plural, singular) {
    addInflection('singular', plural, singular);
  }

  function addIrregular(singular, plural) {
    var sReg = RegExp(singular + '$', 'i');
    var pReg = RegExp(plural + '$', 'i');
    addPlural(sReg, plural);
    addPlural(pReg, plural);
    addSingular(pReg, singular);
    addSingular(sReg, singular);
  }

  function addUncountable(set) {
    forEach(spaceSplit(set), function(str) {
      addPlural(str);
    });
  }

  function addInflection(type, rule, replacement) {
    if (!Inflections[type]) {
      Inflections[type] = new InflectionSet;
    }
    Inflections[type].add(rule, replacement);
  }

  /***
   * @module ES6
   * @description Polyfills that provide basic ES6 compatibility. This module
   *              provides the base for Sugar functionality, but is not a full
   *              polyfill suite.
   *
   ***/


  function getCoercedStringSubject(obj) {
    if (obj == null) {
      throw new TypeError('String required.');
    }
    return String(obj);
  }

  function getCoercedSearchString(obj) {
    if (isRegExp(obj)) {
      throw new TypeError();
    }
    return String(obj);
  }

  defineInstancePolyfill(sugarString, {

    /***
     * @method includes(search, [pos] = 0)
     * @returns Boolean
     * @polyfill ES6
     * @short Returns true if `search` is contained within the string.
     * @extra Search begins at [pos], which defaults to the beginning of the
     *        string. Sugar enhances this method to allow matching a regex.
     *
     * @example
     *
     *   'jumpy'.includes('py')      -> true
     *   'broken'.includes('ken', 3) -> true
     *   'broken'.includes('bro', 3) -> false
     *
     ***/
    'includes': function(searchString) {
      // Force compiler to respect argument length.
      var argLen = arguments.length, pos = arguments[1];
      var str = getCoercedStringSubject(this);
      searchString = getCoercedSearchString(searchString);
      return str.indexOf(searchString, pos) !== -1;
    },

    /***
     * @method startsWith(search, [pos] = 0)
     * @returns Boolean
     * @polyfill ES6
     * @short Returns true if the string starts with substring `search`.
     * @extra Search begins at [pos], which defaults to the entire string length.
     *
     * @example
     *
     *   'hello'.startsWith('hell')   -> true
     *   'hello'.startsWith('HELL')   -> false
     *   'hello'.startsWith('ell', 1) -> true
     *
     ***/
    'startsWith': function(searchString) {
      // Force compiler to respect argument length.
      var argLen = arguments.length, position = arguments[1];
      var str, start, pos, len, searchLength;
      str = getCoercedStringSubject(this);
      searchString = getCoercedSearchString(searchString);
      pos = +position || 0;
      len = str.length;
      start = min(max(pos, 0), len);
      searchLength = searchString.length;
      if (searchLength + start > len) {
        return false;
      }
      if (str.substr(start, searchLength) === searchString) {
        return true;
      }
      return false;
    },

    /***
     * @method endsWith(search, [pos] = length)
     * @returns Boolean
     * @polyfill ES6
     * @short Returns true if the string ends with substring `search`.
     * @extra Search ends at [pos], which defaults to the entire string length.
     *
     * @example
     *
     *   'jumpy'.endsWith('py')    -> true
     *   'jumpy'.endsWith('MPY')   -> false
     *   'jumpy'.endsWith('mp', 4) -> false
     *
     ***/
    'endsWith': function(searchString) {
      // Force compiler to respect argument length.
      var argLen = arguments.length, endPosition = arguments[1];
      var str, start, end, pos, len, searchLength;
      str = getCoercedStringSubject(this);
      searchString = getCoercedSearchString(searchString);
      len = str.length;
      pos = len;
      if (isDefined(endPosition)) {
        pos = +endPosition || 0;
      }
      end = min(max(pos, 0), len);
      searchLength = searchString.length;
      start = end - searchLength;
      if (start < 0) {
        return false;
      }
      if (str.substr(start, searchLength) === searchString) {
        return true;
      }
      return false;
    },

    /***
     * @method repeat([num] = 0)
     * @returns String
     * @polyfill ES6
     * @short Returns the string repeated [num] times.
     *
     * @example
     *
     *   'jumpy'.repeat(2) -> 'jumpyjumpy'
     *   'a'.repeat(5)     -> 'aaaaa'
     *   'a'.repeat(0)     -> ''
     *
     ***/
    'repeat': function(num) {
      num = coercePositiveInteger(num);
      return repeatString(this, num);
    }

  });

  defineStaticPolyfill(sugarNumber, {

    /***
     * @method isNaN(value)
     * @returns Boolean
     * @polyfill ES6
     * @static
     * @short Returns true only if the number is `NaN`.
     * @extra This is differs from the global `isNaN`, which returns true for
     *        anything that is not a number.
     *
     * @example
     *
     *   Number.isNaN(NaN) -> true
     *   Number.isNaN('n') -> false
     *
     ***/
    'isNaN': function(obj) {
      return isRealNaN(obj);
    }

  });

  function getCoercedObject(obj) {
    if (obj == null) {
      throw new TypeError('Object required.');
    }
    return coercePrimitiveToObject(obj);
  }

  defineStaticPolyfill(sugarArray, {

    /***
     * @method from(a, [mapFn], [context])
     * @returns Mixed
     * @polyfill ES6
     * @static
     * @short Creates an array from an array-like object.
     * @extra If [mapFn] is passed, it will be map each element of the array.
     *        [context] is the `this` object if passed.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   Array.from({0:'a',1:'b',length:2}); -> ['a','b']
     *
     ***/
    'from': function(a) {
      // Force compiler to respect argument length.
      var argLen = arguments.length, mapFn = arguments[1], context = arguments[2];
      var len, arr;
      if (isDefined(mapFn)) {
        assertCallable(mapFn);
      }
      a = getCoercedObject(a);
      len = trunc(max(0, a.length || 0));
      if (!isArrayIndex(len)) {
        throw new RangeError('Invalid array length');
      }
      if (isFunction(this)) {
        arr = new this(len);
        arr.length = len;
      } else {
        arr = new Array(len);
      }
      for (var i = 0; i < len; i++) {
        setProperty(arr, i, isDefined(mapFn) ? mapFn.call(context, a[i], i) : a[i], true);
      }
      return arr;
    }

  });

  defineInstancePolyfill(sugarArray, {

    'find': function(f) {
      // Force compiler to respect argument length.
      var argLen = arguments.length, context = arguments[1];
      assertCallable(f);
      for (var i = 0, len = this.length; i < len; i++) {
        if (f.call(context, this[i], i, this)) {
          return this[i];
        }
      }
    },

    'findIndex': function(f) {
      // Force compiler to respect argument length.
      var argLen = arguments.length, context = arguments[1];
      assertCallable(f);
      for (var i = 0, len = this.length; i < len; i++) {
        if (f.call(context, this[i], i, this)) {
          return i;
        }
      }
      return -1;
    }

  });

  /***
   * @module ES7
   * @description Polyfills that provide basic ES7 compatibility. This module
   *              provides the base for Sugar functionality, but is not a full
   *              polyfill suite.
   *
   ***/


  function sameValueZero(a, b) {
    if (isRealNaN(a)) {
      return isRealNaN(b);
    }
    return a === b ? a !== 0 || 1 / a === 1 / b : false;
  }

  defineInstancePolyfill(sugarArray, {

    /***
     * @method includes(search, [fromIndex] = 0)
     * @returns Boolean
     * @polyfill ES7
     * @short Returns true if `search` is contained within the array.
     * @extra Search begins at [fromIndex], which defaults to the beginning of the
     *        array.
     *
     * @example
     *
     *   [1,2,3].includes(2)    -> true
     *   [1,2,3].includes(4)    -> false
     *   [1,2,3].includes(2, 3) -> false
     *
     ***/
    'includes': function(search) {
      // Force compiler to respect argument length.
      var argLen = arguments.length, fromIndex = arguments[1];
      var arr = this, len;
      if (isString(arr)) return arr.includes(search, fromIndex);
      fromIndex = fromIndex ? fromIndex.valueOf() : 0;
      len = arr.length;
      if (fromIndex < 0) {
        fromIndex = max(0, fromIndex + len);
      }
      for (var i = fromIndex; i < len; i++) {
        if (sameValueZero(search, arr[i])) {
          return true;
        }
      }
      return false;
    }

  });

  /***
   * @module String
   * @description String manupulation, encoding, truncation, and formatting, and more.
   *
   ***/


  // Flag allowing native string methods to be enhanced
  var STRING_ENHANCEMENTS_FLAG = 'enhanceString';

  // Matches non-punctuation characters except apostrophe for capitalization.
  var CAPITALIZE_REG = /[^\u0000-\u0040\u005B-\u0060\u007B-\u007F]+('s)?/g;

  // Regex matching camelCase.
  var CAMELIZE_REG = /(^|_)([^_]+)/g;

  // Reference to native String#includes to enhance later.
  var nativeIncludes = String.prototype.includes;

  // Format matcher for String#format.
  var stringFormatMatcher = createFormatMatcher(deepGetProperty);

  function stringEach(str, search, fn) {
    var chunks, chunk, reg, result = [];
    if (isFunction(search)) {
      fn = search;
      reg = /[\s\S]/g;
    } else if (!search) {
      reg = /[\s\S]/g;
    } else if (isString(search)) {
      reg = RegExp(escapeRegExp(search), 'gi');
    } else if (isRegExp(search)) {
      reg = RegExp(search.source, getRegExpFlags(search, 'g'));
    }
    // Getting the entire array of chunks up front as we need to
    // pass this into the callback function as an argument.
    chunks = runGlobalMatch(str, reg);

    if (chunks) {
      for(var i = 0, len = chunks.length, r; i < len; i++) {
        chunk = chunks[i];
        result[i] = chunk;
        if (fn) {
          r = fn.call(str, chunk, i, chunks);
          if (r === false) {
            break;
          } else if (isDefined(r)) {
            result[i] = r;
          }
        }
      }
    }
    return result;
  }

  // "match" in < IE9 has enumable properties that will confuse for..in
  // loops, so ensure that the match is a normal array by manually running
  // "exec". Note that this method is also slightly more performant.
  function runGlobalMatch(str, reg) {
    var result = [], match, lastLastIndex;
    while ((match = reg.exec(str)) != null) {
      if (reg.lastIndex === lastLastIndex) {
        reg.lastIndex += 1;
      } else {
        result.push(match[0]);
      }
      lastLastIndex = reg.lastIndex;
    }
    return result;
  }

  function stringCodes(str, fn) {
    var codes = new Array(str.length), i, len;
    for(i = 0, len = str.length; i < len; i++) {
      var code = str.charCodeAt(i);
      codes[i] = code;
      if (fn) {
        fn.call(str, code, i, str);
      }
    }
    return codes;
  }

  function stringUnderscore(str) {
    var areg = Inflections.acronyms && Inflections.acronyms.reg;
    return str
      .replace(/[-\s]+/g, '_')
      .replace(areg, function(acronym, index) {
        return (index > 0 ? '_' : '') + acronym.toLowerCase();
      })
      .replace(/([A-Z\d]+)([A-Z][a-z])/g,'$1_$2')
      .replace(/([a-z\d])([A-Z])/g,'$1_$2')
      .toLowerCase();
  }

  function stringCamelize(str, upper) {
    str = stringUnderscore(str);
    return str.replace(CAMELIZE_REG, function(match, pre, word, index) {
      var cap = upper !== false || index > 0, acronym;
      acronym = getAcronym(word);
      if (acronym && cap) {
        return acronym;
      }
      return cap ? stringCapitalize(word, true) : word;
    });
  }

  function stringCapitalize(str, downcase, all) {
    if (downcase) {
      str = str.toLowerCase();
    }
    return all ? str.replace(CAPITALIZE_REG, simpleCapitalize) : simpleCapitalize(str);
  }

  function reverseString(str) {
    return str.split('').reverse().join('');
  }

  function stringReplaceAll(str, f, replace) {
    var i = 0, tokens;
    if (isString(f)) {
      f = RegExp(escapeRegExp(f), 'g');
    } else if (f && !f.global) {
      f = RegExp(f.source, getRegExpFlags(f, 'g'));
    }
    if (!replace) {
      replace = '';
    } else {
      tokens = replace;
      replace = function() {
        var t = tokens[i++];
        return t != null ? t : '';
      };
    }
    return str.replace(f, replace);
  }

  function numberOrIndex(str, n, from) {
    if (isString(n)) {
      n = str.indexOf(n);
      if (n === -1) {
        n = from ? str.length : 0;
      }
    }
    return n;
  }

  function callIncludesWithRegexSupport(str, search, position) {
    if (!isRegExp(search)) {
      return nativeIncludes.call(str, search, position);
    }
    if (position) {
      str = str.slice(position);
    }
    return search.test(str);
  }

  defineInstance(sugarString, {

    // Enhancment to String#includes to allow a regex.
    'includes': fixArgumentLength(callIncludesWithRegexSupport),

    /***
     * @method lines([eachLineFn])
     * @returns Array
     * @short Runs [eachLineFn] against each line in the string, and returns an array.
     *
     * @callback eachLineFn
     *
     *   line  The current line.
     *   i     The current index.
     *   arr   An array of all lines.
     *
     * @example
     *
     *   lineText.lines() -> array of lines
     *   lineText.lines(function(l) {
     *     // Called once per line
     *   });
     *
     * @param {eachLineFn} [eachLineFn]
     * @callbackParam {string} line
     * @callbackParam {number} i
     * @callbackParam {Array<string>} arr
     *
     ***/
    'lines': function(str, eachLineFn) {
      return stringEach(trim(str), /^.*$/gm, eachLineFn);
    }

  }, [ENHANCEMENTS_FLAG, STRING_ENHANCEMENTS_FLAG]);

  defineInstance(sugarString, {

    /***
     * @method at(index, [loop] = false)
     * @returns Mixed
     * @short Gets the character(s) at a given index.
     * @extra When [loop] is true, overshooting the end of the string will begin
     *        counting from the other end. `index` may be negative. If `index` is
     *        an array, multiple elements will be returned.
     * @example
     *
     *   'jumpy'.at(0)             -> 'j'
     *   'jumpy'.at(2)             -> 'm'
     *   'jumpy'.at(5)             -> ''
     *   'jumpy'.at(5, true)       -> 'j'
     *   'jumpy'.at(-1)            -> 'y'
     *   'lucky charms'.at([2, 4]) -> ['u','k']
     *
     * @param {number|Array<number>} index
     * @param {boolean} [loop]
     *
     ***/
    'at': function(str, index, loop) {
      return getEntriesForIndexes(str, index, loop, true);
    },

    /***
     * @method forEach([search], [eachFn])
     * @returns Array
     * @short Runs callback [eachFn] against every character in the string, or
     *        every every occurence of [search] if it is provided.
     * @extra Returns an array of matches. [search] may be either a string or
     *        regex, and defaults to every character in the string. If [eachFn]
     *        returns false at any time it will break out of the loop.
     *
     * @callback eachFn
     *
     *   match  The current match.
     *   i      The current index.
     *   arr    An array of all matches.
     *
     * @example
     *
     *   'jumpy'.forEach(log)     -> ['j','u','m','p','y']
     *   'jumpy'.forEach(/[r-z]/) -> ['u','y']
     *   'jumpy'.forEach(/mp/)    -> ['mp']
     *   'jumpy'.forEach(/[r-z]/, function(m) {
     *     // Called twice: "u", "y"
     *   });
     *
     * @signature forEach(eachFn)
     * @param {string|RegExp} [search]
     * @param {eachFn} [eachFn]
     * @callbackParam {string} match
     * @callbackParam {number} i
     * @callbackParam {Array<string>} arr
     *
     ***/
    'forEach': function(str, search, eachFn) {
      return stringEach(str, search, eachFn);
    },

    /***
     * @method chars([eachCharFn])
     * @returns Array
     * @short Runs [eachCharFn] against each character in the string, and returns an array.
     *
     * @callback eachCharFn
     *
     *   char  The current character.
     *   i     The current index.
     *   arr   An array of all characters.
     *
     * @example
     *
     *   'jumpy'.chars() -> ['j','u','m','p','y']
     *   'jumpy'.chars(function(c) {
     *     // Called 5 times: "j","u","m","p","y"
     *   });
     *
     * @param {eachCharFn} [eachCharFn]
     * @callbackParam {string} char
     * @callbackParam {number} i
     * @callbackParam {Array<string>} arr
     *
     ***/
    'chars': function(str, search, eachCharFn) {
      return stringEach(str, search, eachCharFn);
    },

    /***
     * @method codes([eachCodeFn])
     * @returns Array
     * @short Runs callback [eachCodeFn] against each character code in the string.
     *        Returns an array of character codes.
     *
     * @callback eachCodeFn
     *
     *   code  The current character code.
     *   i     The current index.
     *   str   The string being operated on.
     *
     * @example
     *
     *   'jumpy'.codes() -> [106,117,109,112,121]
     *   'jumpy'.codes(function(c) {
     *     // Called 5 times: 106, 117, 109, 112, 121
     *   });
     *
     * @param {eachCodeFn} [eachCodeFn]
     * @callbackParam {number} code
     * @callbackParam {number} i
     * @callbackParam {string} str
     *
     ***/
    'codes': function(str, eachCodeFn) {
      return stringCodes(str, eachCodeFn);
    },

    /***
     * @method shift(n)
     * @returns Array
     * @short Shifts each character in the string `n` places in the character map.
     *
     * @example
     *
     *   'a'.shift(1)  -> 'b'
     *   'ク'.shift(1) -> 'グ'
     *
     * @param {number} n
     *
     ***/
    'shift': function(str, n) {
      var result = '';
      n = n || 0;
      stringCodes(str, function(c) {
        result += chr(c + n);
      });
      return result;
    },

    /***
     * @method isBlank()
     * @returns Boolean
     * @short Returns true if the string has length 0 or contains only whitespace.
     *
     * @example
     *
     *   ''.isBlank()      -> true
     *   '   '.isBlank()   -> true
     *   'noway'.isBlank() -> false
     *
     ***/
    'isBlank': function(str) {
      return trim(str).length === 0;
    },

    /***
     * @method isEmpty()
     * @returns Boolean
     * @short Returns true if the string has length 0.
     *
     * @example
     *
     *   ''.isEmpty()  -> true
     *   'a'.isBlank() -> false
     *   ' '.isBlank() -> false
     *
     ***/
    'isEmpty': function(str) {
      return str.length === 0;
    },

    /***
     * @method remove(f)
     * @returns String
     * @short Removes the first occurrence of `f` in the string.
     * @extra `f` can be a either case-sensitive string or a regex. In either case
     *        only the first match will be removed. To remove multiple occurrences,
     *        use `removeAll`.
     *
     * @example
     *
     *   'schfifty five'.remove('f')      -> 'schifty five'
     *   'schfifty five'.remove(/[a-f]/g) -> 'shfifty five'
     *
     * @param {string|RegExp} f
     *
     ***/
    'remove': function(str, f) {
      return str.replace(f, '');
    },

    /***
     * @method removeAll(f)
     * @returns String
     * @short Removes any occurences of `f` in the string.
     * @extra `f` can be either a case-sensitive string or a regex. In either case
     *        all matches will be removed. To remove only a single occurence, use
     *        `remove`.
     *
     * @example
     *
     *   'schfifty five'.removeAll('f')     -> 'schity ive'
     *   'schfifty five'.removeAll(/[a-f]/) -> 'shity iv'
     *
     * @param {string|RegExp} f
     *
     ***/
    'removeAll': function(str, f) {
      return stringReplaceAll(str, f);
    },

    /***
     * @method reverse()
     * @returns String
     * @short Reverses the string.
     *
     * @example
     *
     *   'jumpy'.reverse()        -> 'ypmuj'
     *   'lucky charms'.reverse() -> 'smrahc ykcul'
     *
     ***/
    'reverse': function(str) {
      return reverseString(str);
    },

    /***
     * @method compact()
     * @returns String
     * @short Compacts whitespace in the string to a single space and trims the ends.
     *
     * @example
     *
     *   'too \n much \n space'.compact() -> 'too much space'
     *   'enough \n '.compact()           -> 'enought'
     *
     ***/
    'compact': function(str) {
      return trim(str).replace(/([\r\n\s　])+/g, function(match, whitespace) {
        return whitespace === '　' ? whitespace : ' ';
      });
    },

    /***
     * @method from([index] = 0)
     * @returns String
     * @short Returns a section of the string starting from [index].
     *
     * @example
     *
     *   'lucky charms'.from()   -> 'lucky charms'
     *   'lucky charms'.from(7)  -> 'harms'
     *
     * @param {number} [index]
     *
     ***/
    'from': function(str, from) {
      return str.slice(numberOrIndex(str, from, true));
    },

    /***
     * @method camelize([upper] = true)
     * @returns String
     * @short Converts underscores and hyphens to camel case.
     * @extra If [upper] is true, the string will be UpperCamelCase. If the
     *        inflections module is included, acronyms can also be defined that
     *        will be used when camelizing.
     *
     * @example
     *
     *   'caps_lock'.camelize()              -> 'CapsLock'
     *   'moz-border-radius'.camelize()      -> 'MozBorderRadius'
     *   'moz-border-radius'.camelize(false) -> 'mozBorderRadius'
     *   'http-method'.camelize()            -> 'HTTPMethod'
     *
     * @param {boolean} [upper]
     *
     ***/
    'camelize': function(str, upper) {
      return stringCamelize(str, upper);
    },

    /***
     * @method first([n] = 1)
     * @returns String
     * @short Returns the first [n] characters of the string.
     *
     * @example
     *
     *   'lucky charms'.first()  -> 'l'
     *   'lucky charms'.first(3) -> 'luc'
     *
     * @param {number} [n]
     *
     ***/
    'first': function(str, num) {
      if (isUndefined(num)) num = 1;
      return str.substr(0, num);
    },

    /***
     * @method last([n] = 1)
     * @returns String
     * @short Returns the last [n] characters of the string.
     *
     * @example
     *
     *   'lucky charms'.last()  -> 's'
     *   'lucky charms'.last(3) -> 'rms'
     *
     * @param {number} [n]
     *
     ***/
    'last': function(str, num) {
      if (isUndefined(num)) num = 1;
      var start = str.length - num < 0 ? 0 : str.length - num;
      return str.substr(start);
    },

    /***
     * @method capitalize([lower] = false, [all] = false)
     * @returns String
     * @short Capitalizes the first character of the string.
     * @extra If [lower] is true, the remainder of the string will be downcased.
     *        If [all] is true, all words in the string will be capitalized.
     *
     * @example
     *
     *   'hello'.capitalize()           -> 'Hello'
     *   'HELLO'.capitalize(true)       -> 'Hello'
     *   'hello kitty'.capitalize()     -> 'Hello kitty'
     *   'hEllO kItTy'.capitalize(true, true) -> 'Hello Kitty'
     *
     * @param {boolean} [lower]
     * @param {boolean} [all]
     *
     ***/
    'capitalize': function(str, lower, all) {
      return stringCapitalize(str, lower, all);
    },

    /***
     * @method singularize()
     * @returns String
     * @short Returns the singular form of the last word in the string.
     *
     * @example
     *
     *   'posts'.singularize()       -> 'post'
     *   'octopi'.singularize()      -> 'octopus'
     *   'sheep'.singularize()       -> 'sheep'
     *   'word'.singularize()        -> 'word'
     *   'CamelOctopi'.singularize() -> 'CamelOctopus'
     *
     ***/
    'singularize': function(str) {
      return inflectPlurals('singular', String(str));
    },

    /***
     * @method underscore()
     * @returns String
     * @short Converts hyphens and camel casing to underscores.
     *
     * @example
     *
     *   'a-farewell-to-arms'.underscore() -> 'a_farewell_to_arms'
     *   'capsLock'.underscore()           -> 'caps_lock'
     *
     ***/
    'underscore': function(str) {
      return stringUnderscore(str);
    }

  });

  defineInstanceWithArguments(sugarString, {

    /***
     * @method replaceAll(f, [str1], [str2], ...)
     * @returns String
     * @short Replaces all occurences of `f` with arguments passed.
     * @extra This method is intended to be a quick way to perform multiple string
     *        replacements quickly when the replacement token differs depending on
     *        position. `f` can be either a case-sensitive string or a regex.
     *        In either case all matches will be replaced.
     *
     * @example
     *
     *   '-x -y -z'.replaceAll('-', 1, 2, 3)               -> '1x 2y 3z'
     *   'one and two'.replaceAll(/one|two/, '1st', '2nd') -> '1st and 2nd'
     *
     * @param {string|RegExp} f
     * @param {string} [str1]
     * @param {string} [str2]
     *
     ***/
    'replaceAll': function(str, f, args) {
      return stringReplaceAll(str, f, args);
    },

    /***
     * @method format(obj1, [obj2], ...)
     * @returns String
     * @short Replaces `{}` tokens in the string with arguments or properties.
     * @extra Tokens support `deep properties`. If a single object is passed, its
     *        properties can be accessed by keywords such as `{name}`. If multiple
     *        objects or a non-object are passed, they can be accessed by the
     *        argument position like `{0}`. Literal braces in the string can be
     *        escaped by repeating them.
     *
     * @example
     *
     *   'Welcome, {name}.'.format({ name: 'Bill' }) -> 'Welcome, Bill.'
     *   'You are {0} years old today.'.format(5)    -> 'You are 5 years old today.'
     *   '{0.name} and {1.name}'.format(users)       -> logs first two users' names
     *   '${currencies.usd.balance}'.format(Harry)   -> "$500"
     *   '{{Hello}}'.format('Hello')                 -> "{Hello}"
     *
     * @param {any} [obj1]
     * @param {any} [obj2]
     *
     ***/
    'format': function(str, args) {
      var arg1 = args[0] && args[0].valueOf();
      // Unwrap if a single object is passed in.
      if (args.length === 1 && isObjectType(arg1)) {
        args = arg1;
      }
      return stringFormatMatcher(str, args);
    }

  });

  buildInflectionSet();

  buildCommonPlurals();

  /***
   * @module Array
   * @description Array manipulation and traversal, alphanumeric sorting and collation.
   *
   ***/


  var HALF_WIDTH_NINE = 0x39;

  var FULL_WIDTH_NINE = 0xff19;

  // Undefined array elements in < IE8 will not be visited by concat
  // and so will not be copied. This means that non-sparse arrays will
  // become sparse, so detect for this here.
  var HAS_CONCAT_BUG = !('0' in [].concat(undefined).concat());

  var ARRAY_OPTIONS = {
    'sortIgnore':      null,
    'sortNatural':     true,
    'sortIgnoreCase':  true,
    'sortOrder':       getSortOrder(),
    'sortCollate':     collateStrings,
    'sortEquivalents': getSortEquivalents()
  };

  /***
   * @method getOption(name)
   * @returns Mixed
   * @accessor
   * @short Gets an option used internally by Array.
   * @extra Options listed below. Current options are for sorting strings with
   *        `sortBy`.
   *
   * @example
   *
   *   Sugar.Array.getOption('sortNatural')
   *
   * @param {string} name
   *
   ***
   * @method setOption(name, value)
   * @accessor
   * @short Sets an option used internally by Array.
   * @extra Options listed below. Current options are for sorting strings with
   *        `sortBy`. If `value` is `null`, the default value will be restored.
   *
   * @options
   *
   *   sortIgnore        A regex to ignore when sorting. An example usage of this
   *                     option would be to ignore numbers in a list to instead
   *                     sort by the first text that appears. Default is `null`.
   *
   *   sortIgnoreCase    A boolean that ignores case when sorting.
   *                     Default is `true`.
   *
   *   sortNatural       A boolean that turns on natural sorting. "Natural" means
   *                     that numerals like "10" will be sorted after "9" instead
   *                     of after "1". Default is `true`.
   *
   *   sortOrder         A string of characters to use as the base sort order. The
   *                     default is an order natural to most major world languages.
   *
   *   sortEquivalents   A table of equivalent characters used when sorting. The
   *                     default produces a natural sort order for most world
   *                     languages, however can be modified for others. For
   *                     example, setting "ä" and "ö" to `null` in the table would
   *                     produce a Scandanavian sort order. Note that setting this
   *                     option to `null` will restore the default table, but any
   *                     mutations made to that table will persist.
   *
   *   sortCollate       The collation function used when sorting strings. The
   *                     default function produces a natural sort order that can
   *                     be customized with the other "sort" options. Overriding
   *                     the function directly here will also override these
   *                     options.
   *
   * @example
   *
   *   Sugar.Array.setOption('sortIgnore', /^\d+\./)
   *   Sugar.Array.setOption('sortIgnoreCase', false)
   *
   * @signature setOption(options)
   * @param {ArrayOptions} options
   * @param {string} name
   * @param {any} value
   * @option {RegExp} [sortIgnore]
   * @option {boolean} [sortIgnoreCase]
   * @option {boolean} [sortNatural]
   * @option {string} [sortOrder]
   * @option {Object} [sortEquivalents]
   * @option {Function} [sortCollate]
   *
   ***/
  var _arrayOptions = defineOptionsAccessor(sugarArray, ARRAY_OPTIONS);

  function setArrayChainableConstructor() {
    setChainableConstructor(sugarArray, arrayCreate);
  }

  function isArrayOrInherited(obj) {
    return obj && obj.constructor && isArray(obj.constructor.prototype);
  }

  function arrayCreate(obj, clone) {
    var arr;
    if (isArrayOrInherited(obj)) {
      arr = clone ? arrayClone(obj) : obj;
    } else if (isObjectType(obj) || isString(obj)) {
      arr = Array.from(obj);
    } else if (isDefined(obj)) {
      arr = [obj];
    }
    return arr || [];
  }

  function arrayClone(arr) {
    var clone = new Array(arr.length);
    forEach(arr, function(el, i) {
      clone[i] = el;
    });
    return clone;
  }

  function arrayConcat(arr1, arr2) {
    if (HAS_CONCAT_BUG) {
      return arraySafeConcat(arr1, arr2);
    }
    return arr1.concat(arr2);
  }

  // Avoids issues with [undefined] in < IE9
  function arrayWrap(obj) {
    var arr = [];
    arr.push(obj);
    return arr;
  }

  // Avoids issues with concat in < IE8
  function arraySafeConcat(arr, arg) {
    var result = arrayClone(arr), len = result.length, arr2;
    arr2 = isArray(arg) ? arg : [arg];
    result.length += arr2.length;
    forEach(arr2, function(el, i) {
      result[len + i] = el;
    });
    return result;
  }

  function arrayAppend(arr, el, index) {
    var spliceArgs;
    index = +index;
    if (isNaN(index)) {
      index = arr.length;
    }
    spliceArgs = [index, 0];
    if (isDefined(el)) {
      spliceArgs = spliceArgs.concat(el);
    }
    arr.splice.apply(arr, spliceArgs);
    return arr;
  }

  function arrayRemove(arr, f) {
    var matcher = getMatcher(f), i = 0;
    while(i < arr.length) {
      if (matcher(arr[i], i, arr)) {
        arr.splice(i, 1);
      } else {
        i++;
      }
    }
    return arr;
  }

  function arrayExclude(arr, f) {
    var result = [], matcher = getMatcher(f);
    for (var i = 0; i < arr.length; i++) {
      if (!matcher(arr[i], i, arr)) {
        result.push(arr[i]);
      }
    }
    return result;
  }

  function arrayUnique(arr, map) {
    var result = [], obj = {}, refs = [];
    forEach(arr, function(el, i) {
      var transformed = map ? mapWithShortcuts(el, map, arr, [el, i, arr]) : el;
      var key = serializeInternal(transformed, refs);
      if (!hasOwn(obj, key)) {
        result.push(el);
        obj[key] = true;
      }
    });
    return result;
  }

  function arrayFlatten(arr, level, current) {
    var result = [];
    level = level || Infinity;
    current = current || 0;
    forEach(arr, function(el) {
      if (isArray(el) && current < level) {
        result = result.concat(arrayFlatten(el, level, current + 1));
      } else {
        result.push(el);
      }
    });
    return result;
  }

  function arrayCompact(arr, all) {
    return filter(arr, function(el) {
      return el || (!all && el != null && el.valueOf() === el.valueOf());
    });
  }

  function arrayShuffle(arr) {
    arr = arrayClone(arr);
    var i = arr.length, j, x;
    while(i) {
      j = (Math.random() * i) | 0;
      x = arr[--i];
      arr[i] = arr[j];
      arr[j] = x;
    }
    return arr;
  }

  function arrayGroupBy(arr, map, fn) {
    var result = {}, key;
    forEach(arr, function(el, i) {
      key = mapWithShortcuts(el, map, arr, [el, i, arr]);
      if (!hasOwn(result, key)) {
        result[key] = [];
      }
      result[key].push(el);
    });
    if (fn) {
      forEachProperty(result, fn);
    }
    return result;
  }

  function arrayIntersectOrSubtract(arr1, arr2, subtract) {
    var result = [], obj = {}, refs = [];
    if (!isArray(arr2)) {
      arr2 = arrayWrap(arr2);
    }
    forEach(arr2, function(el) {
      obj[serializeInternal(el, refs)] = true;
    });
    forEach(arr1, function(el) {
      var key = serializeInternal(el, refs);
      if (hasOwn(obj, key) !== subtract) {
        delete obj[key];
        result.push(el);
      }
    });
    return result;
  }

  function compareValue(aVal, bVal) {
    var cmp, i, collate;
    if (isString(aVal) && isString(bVal)) {
      collate = _arrayOptions('sortCollate');
      return collate(aVal, bVal);
    } else if (isArray(aVal) && isArray(bVal)) {
      if (aVal.length < bVal.length) {
        return -1;
      } else if (aVal.length > bVal.length) {
        return 1;
      } else {
        for(i = 0; i < aVal.length; i++) {
          cmp = compareValue(aVal[i], bVal[i]);
          if (cmp !== 0) {
            return cmp;
          }
        }
        return 0;
      }
    }
    return aVal < bVal ? -1 : aVal > bVal ? 1 : 0;
  }

  function codeIsNumeral(code) {
    return (code >= HALF_WIDTH_ZERO && code <= HALF_WIDTH_NINE) ||
           (code >= FULL_WIDTH_ZERO && code <= FULL_WIDTH_NINE);
  }

  function collateStrings(a, b) {
    var aValue, bValue, aChar, bChar, aEquiv, bEquiv, index = 0, tiebreaker = 0;

    var sortOrder       = _arrayOptions('sortOrder');
    var sortIgnore      = _arrayOptions('sortIgnore');
    var sortNatural     = _arrayOptions('sortNatural');
    var sortIgnoreCase  = _arrayOptions('sortIgnoreCase');
    var sortEquivalents = _arrayOptions('sortEquivalents');

    a = getCollationReadyString(a, sortIgnore, sortIgnoreCase);
    b = getCollationReadyString(b, sortIgnore, sortIgnoreCase);

    do {

      aChar  = getCollationCharacter(a, index, sortEquivalents);
      bChar  = getCollationCharacter(b, index, sortEquivalents);
      aValue = getSortOrderIndex(aChar, sortOrder);
      bValue = getSortOrderIndex(bChar, sortOrder);

      if (aValue === -1 || bValue === -1) {
        aValue = a.charCodeAt(index) || null;
        bValue = b.charCodeAt(index) || null;
        if (sortNatural && codeIsNumeral(aValue) && codeIsNumeral(bValue)) {
          aValue = stringToNumber(a.slice(index));
          bValue = stringToNumber(b.slice(index));
        }
      } else {
        aEquiv = aChar !== a.charAt(index);
        bEquiv = bChar !== b.charAt(index);
        if (aEquiv !== bEquiv && tiebreaker === 0) {
          tiebreaker = aEquiv - bEquiv;
        }
      }
      index += 1;
    } while(aValue != null && bValue != null && aValue === bValue);
    if (aValue === bValue) return tiebreaker;
    return aValue - bValue;
  }

  function getCollationReadyString(str, sortIgnore, sortIgnoreCase) {
    if (!isString(str)) str = String(str);
    if (sortIgnoreCase) {
      str = str.toLowerCase();
    }
    if (sortIgnore) {
      str = str.replace(sortIgnore, '');
    }
    return str;
  }

  function getCollationCharacter(str, index, sortEquivalents) {
    var chr = str.charAt(index);
    return getOwn(sortEquivalents, chr) || chr;
  }

  function getSortOrderIndex(chr, sortOrder) {
    if (!chr) {
      return null;
    } else {
      return sortOrder.indexOf(chr);
    }
  }

  function getSortOrder() {
    var order = 'AÁÀÂÃĄBCĆČÇDĎÐEÉÈĚÊËĘFGĞHıIÍÌİÎÏJKLŁMNŃŇÑOÓÒÔPQRŘSŚŠŞTŤUÚÙŮÛÜVWXYÝZŹŻŽÞÆŒØÕÅÄÖ';
    return map(order.split(''), function(str) {
      return str + str.toLowerCase();
    }).join('');
  }

  function getSortEquivalents() {
    var equivalents = {};
    forEach(spaceSplit('AÁÀÂÃÄ CÇ EÉÈÊË IÍÌİÎÏ OÓÒÔÕÖ Sß UÚÙÛÜ'), function(set) {
      var first = set.charAt(0);
      forEach(set.slice(1).split(''), function(chr) {
        equivalents[chr] = first;
        equivalents[chr.toLowerCase()] = first.toLowerCase();
      });
    });
    return equivalents;
  }

  defineStatic(sugarArray, {

    /***
     *
     * @method create([obj], [clone] = false)
     * @returns Array
     * @static
     * @short Creates an array from an unknown object.
     * @extra This method is similar to native `Array.from` but is faster when
     *        `obj` is already an array. When [clone] is true, the array will be
     *        shallow cloned. Additionally, it will not fail on `undefined`,
     *        `null`, or numbers, producing an empty array in the case of
     *        `undefined` and wrapping `obj` otherwise.
     *
     * @example
     *
     *   Array.create()          -> []
     *   Array.create(8)         -> [8]
     *   Array.create('abc')     -> ['a','b','c']
     *   Array.create([1,2,3])   -> [1, 2, 3]
     *   Array.create(undefined) -> []
     *
     * @param {number|ArrayLike<T>} [obj]
     * @param {boolean} [clone]
     *
     ***/
    'create': function(obj, clone) {
      return arrayCreate(obj, clone);
    },

    /***
     *
     * @method construct(n, indexMapFn)
     * @returns Array
     * @static
     * @short Constructs an array of `n` length from the values of `indexMapFn`.
     * @extra This function is essentially a shortcut for using `Array.from` with
     *        `new Array(n)`.
     *
     * @callback indexMapFn
     *
     *   i   The index of the current iteration.
     *
     * @example
     *
     *   Array.construct(4, function(i) {
     *     return i * i;
     *   }); -> [0, 1, 4]
     *
     * @param {number} n
     * @param {indexMapFn} indexMapFn
     * @callbackParam {number} i
     * @callbackReturns {ArrayElement} indexMapFn
     *
     ***/
    'construct': function(n, indexMapFn) {
      n = coercePositiveInteger(n);
      return Array.from(new Array(n), function(el, i) {
        return indexMapFn && indexMapFn(i);
      });
    }

  });

  defineInstance(sugarArray, {

    /***
     * @method isEmpty()
     * @returns Boolean
     * @short Returns true if the array has a length of zero.
     *
     * @example
     *
     *   [].isEmpty()    -> true
     *   ['a'].isEmpty() -> false
     *
     ***/
    'isEmpty': function(arr) {
      return arr.length === 0;
    },

    /***
     * @method isEqual(arr)
     * @returns Boolean
     * @short Returns true if the array is equal to `arr`.
     * @extra Objects in the array are considered equal if they are not observably
     *        distinguishable. This method is an instance alias for
     *        `Object.isEqual()`.
     *
     * @example
     *
     *   ['a','b'].isEqual(['a','b']) -> true
     *   ['a','b'].isEqual(['a','c']) -> false
     *   [{a:'a'}].isEqual([{a:'a'}]) -> true
     *   [5].isEqual([Object(5)])     -> false
     *
     * @param {Array} arr
     *
     ***/
    'isEqual': function(a, b) {
      return isEqual(a, b);
    },

    /***
     * @method clone()
     * @returns Array
     * @short Creates a shallow clone of the array.
     *
     * @example
     *
     *   [1,2,3].clone() -> [1,2,3]
     *
     ***/
    'clone': function(arr) {
      return arrayClone(arr);
    },

    /***
     * @method at(index, [loop] = false)
     * @returns ArrayElement
     * @short Gets the element(s) at `index`.
     * @extra When [loop] is true, overshooting the end of the array will begin
     *        counting from the other end. `index` can be negative. If `index` is
     *        an array, multiple elements will be returned.
     *
     * @example
     *
     *   [1,2,3].at(0)       -> 1
     *   [1,2,3].at(2)       -> 3
     *   [1,2,3].at(4)       -> undefined
     *   [1,2,3].at(4, true) -> 2
     *   [1,2,3].at(-1)      -> 3
     *   [1,2,3].at([0, 1])  -> [1, 2]
     *
     * @param {number|number[]} index
     * @param {boolean} [loop]
     *
     ***/
    'at': function(arr, index, loop) {
      return getEntriesForIndexes(arr, index, loop);
    },

    /***
     * @method add(item, [index])
     * @returns Array
     * @short Adds `item` to the array and returns the result as a new array.
     * @extra If `item` is also an array, it will be concatenated instead of
     *        inserted. [index] will control where `item` is added. Use `append`
     *        to modify the original array.
     *
     * @example
     *
     *   [1,2,3,4].add(5)       -> [1,2,3,4,5]
     *   [1,2,3,4].add(8, 1)    -> [1,8,2,3,4]
     *   [1,2,3,4].add([5,6,7]) -> [1,2,3,4,5,6,7]
     *
     * @param {ArrayElement|Array} item
     * @param {number} [index]
     *
     ***/
    'add': function(arr, item, index) {
      return arrayAppend(arrayClone(arr), item, index);
    },

    /***
     * @method subtract(item)
     * @returns Array
     * @short Subtracts `item` from the array and returns the result as a new array.
     * @extra If `item` is also an array, all elements in it will be removed. In
     *        addition to primitives, this method will also deep-check objects for
     *        equality.
     *
     * @example
     *
     *   [1,3,5].subtract([5,7,9])     -> [1,3]
     *   ['a','b'].subtract(['b','c']) -> ['a']
     *   [1,2,3].subtract(2)           -> [1,3]
     *
     * @param {ArrayElement|Array} item
     *
     ***/
    'subtract': function(arr, item) {
      return arrayIntersectOrSubtract(arr, item, true);
    },

    /***
     * @method append(item, [index])
     * @returns Array
     * @short Appends `item` to the array.
     * @extra If `item` is also an array, it will be concatenated instead of
     *        inserted. This method modifies the array! Use `add` to create a new
     *        array. Additionally, `insert` is provided as an alias that reads
     *        better when using an index.
     *
     * @example
     *
     *   [1,2,3,4].append(5)       -> [1,2,3,4,5]
     *   [1,2,3,4].append([5,6,7]) -> [1,2,3,4,5,6,7]
     *   [1,2,3,4].append(8, 1)    -> [1,8,2,3,4]
     *
     * @param {ArrayElement|Array} item
     * @param {number} index
     *
     ***/
    'append': function(arr, item, index) {
      return arrayAppend(arr, item, index);
    },

    /***
     * @method removeAt(start, [end])
     * @returns Array
     * @short Removes element at `start`. If [end] is specified, removes the range
     *        between `start` and [end]. This method will modify the array!
     *
     * @example
     *
     *   ['a','b','c'].removeAt(0) -> ['b','c']
     *   [1,2,3,4].removeAt(1, 2)  -> [1, 4]
     *
     * @param {number} start
     * @param {number} [end]
     *
     ***/
    'removeAt': function(arr, start, end) {
      if (isUndefined(start)) return arr;
      if (isUndefined(end))   end = start;
      arr.splice(start, end - start + 1);
      return arr;
    },

    /***
     * @method unique([map])
     * @returns Array
     * @short Removes all duplicate elements in the array.
     * @extra [map] can be a string or callback type `mapFn` that returns the value
     *        to be uniqued or a string acting as a shortcut. This is most commonly
     *        used when you only need to check a single field that can ensure the
     *        object's uniqueness (such as an `id` field). If [map] is not passed,
     *        then objects will be deep checked for equality.
     *        Supports `deep properties`.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,2,3].unique()            -> [1,2,3]
     *   [{a:'a'},{a:'a'}].unique()    -> [{a:'a'}]
     *
     *   users.unique(function(user) {
     *     return user.id;
     *   }); -> users array uniqued by id
     *
     *   users.unique('id')            -> users array uniqued by id
     *
     * @param {string|mapFn} map
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'unique': function(arr, map) {
      return arrayUnique(arr, map);
    },

    /***
     * @method flatten([limit] = Infinity)
     * @returns Array
     * @short Returns a flattened, one-dimensional copy of the array.
     * @extra You can optionally specify a [limit], which will only flatten to
     *        that depth.
     *
     * @example
     *
     *   [[1], 2, [3]].flatten() -> [1,2,3]
     *   [[1],[],2,3].flatten()  -> [1,2,3]
     *
     * @param {number} [limit]
     *
     ***/
    'flatten': function(arr, limit) {
      return arrayFlatten(arr, limit);
    },

    /***
     * @method first([num] = 1)
     * @returns Mixed
     * @short Returns the first element(s) in the array.
     * @extra When `num` is passed, returns the first `num` elements in the array.
     *
     * @example
     *
     *   [1,2,3].first()  -> 1
     *   [1,2,3].first(2) -> [1,2]
     *
     * @param {number} [num]
     *
     ***/
    'first': function(arr, num) {
      if (isUndefined(num)) return arr[0];
      if (num < 0) num = 0;
      return arr.slice(0, num);
    },

    /***
     * @method last([num] = 1)
     * @returns Mixed
     * @short Returns the last element(s) in the array.
     * @extra When `num` is passed, returns the last `num` elements in the array.
     *
     * @example
     *
     *   [1,2,3].last()  -> 3
     *   [1,2,3].last(2) -> [2,3]
     *
     * @param {number} [num]
     *
     ***/
    'last': function(arr, num) {
      if (isUndefined(num)) return arr[arr.length - 1];
      var start = arr.length - num < 0 ? 0 : arr.length - num;
      return arr.slice(start);
    },

    /***
     * @method from(index)
     * @returns Array
     * @short Returns a slice of the array from `index`.
     *
     * @example
     *
     *   ['a','b','c'].from(1) -> ['b','c']
     *   ['a','b','c'].from(2) -> ['c']
     *
     * @param {number} [index]
     *
     ***/
    'from': function(arr, num) {
      return arr.slice(num);
    },

    /***
     * @method to(index)
     * @returns Array
     * @short Returns a slice of the array up to `index`.
     *
     * @example
     *
     *   ['a','b','c'].to(1) -> ['a']
     *   ['a','b','c'].to(2) -> ['a','b']
     *
     * @param {number} [index]
     *
     ***/
    'to': function(arr, num) {
      if (isUndefined(num)) num = arr.length;
      return arr.slice(0, num);
    },

    /***
     * @method compact([all] = false)
     * @returns Array
     * @short Removes all instances of `undefined`, `null`, and `NaN` from the array.
     * @extra If [all] is `true`, all "falsy" elements will be removed. This
     *        includes empty strings, `0`, and `false`.
     *
     * @example
     *
     *   [1,null,2,undefined,3].compact() -> [1,2,3]
     *   [1,'',2,false,3].compact()       -> [1,'',2,false,3]
     *   [1,'',2,false,3].compact(true)   -> [1,2,3]
     *   [null, [null, 'bye']].compact()  -> ['hi', [null, 'bye']]
     *
     * @param {boolean} [all]
     *
     ***/
    'compact': function(arr, all) {
      return arrayCompact(arr, all);
    },

    /***
     * @method groupBy(map, [groupFn])
     * @returns Object
     * @short Groups the array by `map`.
     * @extra Will return an object whose keys are the mapped from `map`, which
     *        can be a callback of type `mapFn`, or a string acting as a shortcut.
     *        `map` supports `deep properties`. Optionally calls [groupFn] for each group.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @callback groupFn
     *
     *   arr  The current group as an array.
     *   key  The unique key of the current group.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   ['a','aa','aaa'].groupBy('length') -> { 1: ['a'], 2: ['aa'], 3: ['aaa'] }
     *
     *   users.groupBy(function(n) {
     *     return n.age;
     *   }); -> users array grouped by age
     *
     *   users.groupBy('age', function(age, users) {
     *     // iterates each grouping
     *   });
     *
     * @param {string|mapFn} map
     * @param {groupFn} groupFn
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'groupBy': function(arr, map, groupFn) {
      return arrayGroupBy(arr, map, groupFn);
    },

    /***
     * @method inGroups(num, [padding])
     * @returns Array
     * @short Groups the array into `num` arrays.
     * @extra If specified, [padding] will be added to the last array to be of
     *        equal length.
     *
     * @example
     *
     *   [1,2,3,4,5,6,7].inGroups(3)    -> [[1,2,3],[4,5,6],[7]]
     *   [1,2,3,4,5,6,7].inGroups(3, 0) -> [[1,2,3],[4,5,6],[7,0,0]]
     *
     * @param {number} num
     * @param {any} [padding]
     *
     ***/
    'inGroups': function(arr, num, padding) {
      var pad = isDefined(padding);
      var result = new Array(num);
      var divisor = ceil(arr.length / num);
      simpleRepeat(num, function(i) {
        var index = i * divisor;
        var group = arr.slice(index, index + divisor);
        if (pad && group.length < divisor) {
          simpleRepeat(divisor - group.length, function() {
            group.push(padding);
          });
        }
        result[i] = group;
      });
      return result;
    },

    /***
     * @method inGroupsOf(num, [padding] = null)
     * @returns Array
     * @short Groups the array into arrays of `num` elements each.
     * @extra [padding] will be added to the last array to be of equal length.
     *
     * @example
     *
     *   [1,2,3,4,5,6,7].inGroupsOf(4)    -> [ [1,2,3,4], [5,6,7] ]
     *   [1,2,3,4,5,6,7].inGroupsOf(4, 0) -> [ [1,2,3,4], [5,6,7,0] ]
     *
     * @param {number} num
     * @param {any} [padding]
     *
     ***/
    'inGroupsOf': function(arr, num, padding) {
      var result = [], len = arr.length, group;
      if (len === 0 || num === 0) return arr;
      if (isUndefined(num)) num = 1;
      if (isUndefined(padding)) padding = null;
      simpleRepeat(ceil(len / num), function(i) {
        group = arr.slice(num * i, num * i + num);
        while(group.length < num) {
          group.push(padding);
        }
        result.push(group);
      });
      return result;
    },

    /***
     * @method shuffle()
     * @returns Array
     * @short Returns a copy of the array with the elements randomized.
     * @extra Uses Fisher-Yates algorithm.
     *
     * @example
     *
     *   [1,2,3,4].shuffle()  -> [?,?,?,?]
     *
     ***/
    'shuffle': function(arr) {
      return arrayShuffle(arr);
    },

    /***
     * @method sample([num] = 1, [remove] = false)
     * @returns Mixed
     * @short Returns a random element from the array.
     * @extra If [num] is passed, will return an array of [num] elements. If
     *        [remove] is true, sampled elements will also be removed from the
     *        array. [remove] can also be passed in place of [num].
     *
     * @example
     *
     *   [1,2,3,4,5].sample()  -> // Random element
     *   [1,2,3,4,5].sample(1) -> // Array of 1 random element
     *   [1,2,3,4,5].sample(3) -> // Array of 3 random elements
     *
     * @param {number} [num]
     * @param {boolean} [remove]
     *
     ***/
    'sample': function(arr, arg1, arg2) {
      var result = [], num, remove, single;
      if (isBoolean(arg1)) {
        remove = arg1;
      } else {
        num = arg1;
        remove = arg2;
      }
      if (isUndefined(num)) {
        num = 1;
        single = true;
      }
      if (!remove) {
        arr = arrayClone(arr);
      }
      num = min(num, arr.length);
      for (var i = 0, index; i < num; i++) {
        index = trunc(Math.random() * arr.length);
        result.push(arr[index]);
        arr.splice(index, 1);
      }
      return single ? result[0] : result;
    },

    /***
     * @method sortBy([map], [desc] = false)
     * @returns Array
     * @short Enhanced sorting function that will sort the array by `map`.
     * @extra `map` can be a function of type `sortMapFn`, a string acting as a
     *        shortcut, an array (comparison by multiple values), or blank (direct
     *        comparison of array values). `map` supports `deep properties`.
     *        [desc] will sort the array in descending order. When the field being
     *        sorted on is a string, the resulting order will be determined by an
     *        internal collation algorithm that is optimized for major Western
     *        languages, but can be customized using sorting accessors such as
     *        `sortIgnore`. This method will modify the array!
     *
     * @callback sortMapFn
     *
     *   el   An array element.
     *
     * @example
     *
     *   ['world','a','new'].sortBy('length')       -> ['a','new','world']
     *   ['world','a','new'].sortBy('length', true) -> ['world','new','a']
     *   users.sortBy(function(n) {
     *     return n.age;
     *   }); -> users array sorted by age
     *   users.sortBy('age') -> users array sorted by age
     *
     * @param {string|sortMapFn} [map]
     * @param {boolean} [desc]
     * @callbackParam {ArrayElement} el
     * @callbackReturns {NewArrayElement} sortMapFn
     *
     ***/
    'sortBy': function(arr, map, desc) {
      arr.sort(function(a, b) {
        var aProperty = mapWithShortcuts(a, map, arr, [a]);
        var bProperty = mapWithShortcuts(b, map, arr, [b]);
        return compareValue(aProperty, bProperty) * (desc ? -1 : 1);
      });
      return arr;
    },

    /***
     * @method remove(search)
     * @returns Array
     * @short Removes any element in the array that matches `search`.
     * @extra `search` can be an array element or a function of type `searchFn`.
     *        This method will modify the array! Use `exclude` for a
     *        non-destructive alias. This method implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,3].remove(3)         -> [1,2]
     *   ['a','b','c'].remove(/b/) -> ['a','c']
     *   [{a:1},{b:2}].remove(function(n) {
     *     return n['a'] == 1;
     *   }); -> [{b:2}]
     *
     * @param {ArrayElement|searchFn} search
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'remove': function(arr, f) {
      return arrayRemove(arr, f);
    },

    /***
     * @method exclude(search)
     * @returns Array
     * @short Returns a new array with every element that does not match `search`.
     * @extra `search` can be an array element or a function of type `searchFn`.
     *        This method can be thought of as the inverse of `Array#filter`. It
     *        will not modify the original array, Use `remove` to modify the
     *        array in place. Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,3].exclude(3)         -> [1,2]
     *   ['a','b','c'].exclude(/b/) -> ['a','c']
     *   [{a:1},{b:2}].exclude(function(n) {
     *     return n['a'] == 1;
     *   }); -> [{b:2}]
     *
     * @param {ArrayElement|searchFn} search
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'exclude': function(arr, f) {
      return arrayExclude(arr, f);
    },

    /***
     * @method union(arr)
     * @returns Array
     * @short Returns a new array containing elements in both arrays with
     *        duplicates removed.
     * @extra In addition to primitives, this method will also deep-check objects
     *        for equality.
     *
     * @example
     *
     *   [1,3,5].union([5,7,9])     -> [1,3,5,7,9]
     *   ['a','b'].union(['b','c']) -> ['a','b','c']
     *
     * @param {Array} arr
     *
     ***/
    'union': function(arr1, arr2) {
      return arrayUnique(arrayConcat(arr1, arr2));
    },

    /***
     * @method intersect(arr)
     * @returns Array
     * @short Returns a new array containing any elements that both arrays have in
     *        common.
     * @extra In addition to primitives, this method will also deep-check objects
     *        for equality.
     *
     * @example
     *
     *   [1,3,5].intersect([5,7,9])     -> [5]
     *   ['a','b'].intersect(['b','c']) -> ['b']
     *
     * @param {Array} arr
     *
     ***/
    'intersect': function(arr1, arr2) {
      return arrayIntersectOrSubtract(arr1, arr2, false);
    }

  });

  /***
   * @method insert(item, [index])
   * @returns Array
   * @short Appends `item` to the array at [index].
   * @extra This method is simply a more readable alias for `append` when passing
   *        an index. If `el` is an array it will be joined. This method modifies
   *        the array! Use `add` as a non-destructive alias.
   *
   * @example
   *
   *   [1,3,4,5].insert(2, 1)     -> [1,2,3,4,5]
   *   [1,4,5,6].insert([2,3], 1) -> [1,2,3,4,5,6]
   *
   * @param {ArrayElement|Array} item
   * @param {number} [index]
   *
   ***/
  alias(sugarArray, 'insert', 'append');

  setArrayChainableConstructor();

  /***
   * @module Object
   * @description Object creation, manipulation, comparison, type checking, and more.
   *
   * Much thanks to kangax for his informative aricle about how problems with
   * instanceof and constructor: http://bit.ly/1Qds27W
   *
   ***/


  // Native methods for merging by descriptor when available.
  var getOwnPropertyNames      = Object.getOwnPropertyNames;

  var getOwnPropertySymbols    = Object.getOwnPropertySymbols;

  var getOwnPropertyDescriptor = Object.getOwnPropertyDescriptor;

  function mergeWithOptions(target, source, opts) {
    opts = opts || {};
    return objectMerge(target, source, opts.deep, opts.resolve, opts.hidden, opts.descriptor);
  }

  function iterateOverProperties(hidden, obj, fn) {
    if (getOwnPropertyNames && hidden) {
      iterateOverKeys(getOwnPropertyNames, obj, fn, hidden);
    } else {
      forEachProperty(obj, fn);
    }
    if (getOwnPropertySymbols) {
      iterateOverKeys(getOwnPropertySymbols, obj, fn, hidden);
    }
  }

  // "keys" may include symbols
  function iterateOverKeys(getFn, obj, fn, hidden) {
    var keys = getFn(obj), desc;
    for (var i = 0, key; key = keys[i]; i++) {
      desc = getOwnPropertyDescriptor(obj, key);
      if (desc.enumerable || hidden) {
        fn(obj[key], key);
      }
    }
  }

  function mergeByPropertyDescriptor(target, source, prop, sourceVal) {
    var descriptor = getOwnPropertyDescriptor(source, prop);
    if (isDefined(descriptor.value)) {
      descriptor.value = sourceVal;
    }
    defineProperty(target, prop, descriptor);
  }

  function objectMerge(target, source, deep, resolve, hidden, descriptor) {
    var resolveByFunction = isFunction(resolve), resolveConflicts = resolve !== false;

    if (isUndefined(target)) {
      target = getNewObjectForMerge(source);
    } else if (resolveConflicts && isDate(target) && isDate(source)) {
      // A date's timestamp is a property that can only be reached through its
      // methods, so actively set it up front if both are dates.
      target.setTime(source.getTime());
    }

    if (isPrimitive(target)) {
      // Will not merge into a primitive type, so simply override.
      return source;
    }

    // If the source object is a primitive
    // type then coerce it into an object.
    if (isPrimitive(source)) {
      source = coercePrimitiveToObject(source);
    }

    iterateOverProperties(hidden, source, function(val, key) {
      var sourceVal, targetVal, resolved, goDeep, result;

      sourceVal = source[key];

      // We are iterating over properties of the source, so hasOwnProperty on
      // it is guaranteed to always be true. However, the target may happen to
      // have properties in its prototype chain that should not be considered
      // as conflicts.
      targetVal = getOwn(target, key);

      if (resolveByFunction) {
        result = resolve(key, targetVal, sourceVal, target, source);
        if (isUndefined(result)) {
          // Result is undefined so do not merge this property.
          return;
        } else if (isDefined(result) && result !== Sugar) {
          // If the source returns anything except undefined, then the conflict
          // has been resolved, so don't continue traversing into the object. If
          // the returned value is the Sugar global object, then allowing Sugar
          // to resolve the conflict, so continue on.
          sourceVal = result;
          resolved = true;
        }
      } else if (isUndefined(sourceVal)) {
        // Will not merge undefined.
        return;
      }

      // Regex properties are read-only, so intentionally disallowing deep
      // merging for now. Instead merge by reference even if deep.
      goDeep = !resolved && deep && isObjectType(sourceVal) && !isRegExp(sourceVal);

      if (!goDeep && !resolveConflicts && isDefined(targetVal)) {
        return;
      }

      if (goDeep) {
        sourceVal = objectMerge(targetVal, sourceVal, deep, resolve, hidden, descriptor);
      }

      // getOwnPropertyNames is standing in as
      // a test for property descriptor support
      if (getOwnPropertyNames && descriptor) {
        mergeByPropertyDescriptor(target, source, key, sourceVal);
      } else {
        target[key] = sourceVal;
      }

    });
    return target;
  }

  function getNewObjectForMerge(source) {
    var klass = classToString(source);
    // Primitive types, dates, and regexes have no "empty" state. If they exist
    // at all, then they have an associated value. As we are only creating new
    // objects when they don't exist in the target, these values can come alone
    // for the ride when created.
    if (isArray(source, klass)) {
      return [];
    } else if (isPlainObject(source, klass)) {
      return {};
    } else if (isDate(source, klass)) {
      return new Date(source.getTime());
    } else if (isRegExp(source, klass)) {
      return RegExp(source.source, getRegExpFlags(source));
    } else if (isPrimitive(source && source.valueOf())) {
      return source;
    }
    // If the object is not of a known type, then simply merging its
    // properties into a plain object will result in something different
    // (it will not respond to instanceof operator etc). Similarly we don't
    // want to call a constructor here as we can't know for sure what the
    // original constructor was called with (Events etc), so throw an
    // error here instead. Non-standard types can be handled if either they
    // already exist and simply have their properties merged, if the merge
    // is not deep so their references will simply be copied over, or if a
    // resolve function is used to assist the merge.
    throw new TypeError('Must be a basic data type');
  }

  function clone(source, deep) {
    var target = getNewObjectForMerge(source);
    return objectMerge(target, source, deep, true, true, true);
  }

  function objectSize(obj) {
    return getKeysWithObjectCoercion(obj).length;
  }

  function getKeysWithObjectCoercion(obj) {
    return getKeys(coercePrimitiveToObject(obj));
  }

  function getValues(obj) {
    var values = [];
    forEachProperty(obj, function(val) {
      values.push(val);
    });
    return values;
  }

  function objectSelect(obj, f) {
    return selectFromObject(obj, f, true);
  }

  function objectReject(obj, f) {
    return selectFromObject(obj, f, false);
  }

  function selectFromObject(obj, f, select) {
    var match, result = {};
    f = [].concat(f);
    forEachProperty(obj, function(val, key) {
      match = false;
      for (var i = 0; i < f.length; i++) {
        if (matchInObject(f[i], key)) {
          match = true;
        }
      }
      if (match === select) {
        result[key] = val;
      }
    });
    return result;
  }

  function matchInObject(match, key) {
    if (isRegExp(match)) {
      return match.test(key);
    } else if (isObjectType(match)) {
      return key in match;
    } else {
      return key === String(match);
    }
  }

  function objectRemove(obj, f) {
    var matcher = getMatcher(f);
    forEachProperty(obj, function(val, key) {
      if (matcher(val, key, obj)) {
        delete obj[key];
      }
    });
    return obj;
  }

  function objectExclude(obj, f) {
    var result = {};
    var matcher = getMatcher(f);
    forEachProperty(obj, function(val, key) {
      if (!matcher(val, key, obj)) {
        result[key] = val;
      }
    });
    return result;
  }

  function objectIntersectOrSubtract(obj1, obj2, subtract) {
    if (!isObjectType(obj1)) {
      return subtract ? obj1 : {};
    }
    obj2 = coercePrimitiveToObject(obj2);
    function resolve(key, val, val1) {
      var exists = key in obj2 && isEqual(val1, obj2[key]);
      if (exists !== subtract) {
        return val1;
      }
    }
    return objectMerge({}, obj1, false, resolve);
  }

  /***
   * @method is[Type]()
   * @returns Boolean
   * @short Returns true if the object is an object of that type.
   *
   * @set
   *   isArray
   *   isBoolean
   *   isDate
   *   isError
   *   isFunction
   *   isMap
   *   isNumber
   *   isRegExp
   *   isSet
   *   isString
   *
   * @example
   *
   *   Object.isArray([3]) -> true
   *   Object.isNumber(3)  -> true
   *   Object.isString(8)  -> false
   *
   ***/
  function buildClassCheckMethods() {
    var checks = [isBoolean, isNumber, isString, isDate, isRegExp, isFunction, isArray, isError, isSet, isMap];
    defineInstanceAndStaticSimilar(sugarObject, NATIVE_TYPES, function(methods, name, i) {
      methods['is' + name] = checks[i];
    });
  }

  defineInstanceAndStatic(sugarObject, {

    /***
     * @method size()
     * @returns Number
     * @short Returns the number of properties in the object.
     *
     * @example
     *
     *   Object.size({foo:'bar'}) -> 1
     *
     ***/
    'size': function(obj) {
      return objectSize(obj);
    },

    /***
     * @method isEmpty()
     * @returns Boolean
     * @short Returns true if the number of properties in the object is zero.
     *
     * @example
     *
     *   Object.isEmpty({})    -> true
     *   Object.isEmpty({a:1}) -> false
     *
     ***/
    'isEmpty': function(obj) {
      return objectSize(obj) === 0;
    },

    /***
     * @method isEqual(obj)
     * @returns Boolean
     * @short Returns true if `obj` is equivalent to the object.
     * @extra If both objects are built-in types, they will be considered
     *        equivalent if they are not "observably distinguishable". This means
     *        that primitives and object types, `0` and `-0`, and sparse and
     *        dense arrays are all not equal. Functions and non-built-ins like
     *        instances of user-defined classes and host objects like Element and
     *        Event are strictly compared `===`, and will only be equal if they
     *        are the same reference. Plain objects as well as Arrays will be
     *        traversed into and deeply checked by their non-inherited, enumerable
     *        properties. Other allowed types include Typed Arrays, Sets, Maps,
     *        Arguments, Dates, Regexes, and Errors.
     *
     * @example
     *
     *   Object.isEqual({a:2}, {a:2})         -> true
     *   Object.isEqual({a:2}, {a:3})         -> false
     *   Object.isEqual(5, Object(5))         -> false
     *   Object.isEqual(Object(5), Object(5)) -> true
     *   Object.isEqual(NaN, NaN)             -> false
     *
     * @param {Object} obj
     *
     ***/
    'isEqual': function(obj1, obj2) {
      return isEqual(obj1, obj2);
    },

    /***
     * @method merge(source, [options])
     * @returns Object
     * @short Merges properties from `source` into the object.
     * @extra This method will modify the object! Use `add` for a non-destructive
     *        alias.
     *
     * @options
     *
     *   deep         If `true` deep properties are merged recursively.
     *                (Default `false`)
     *
     *   hidden       If `true`, non-enumerable properties will be merged as well.
     *                (Default `false`)
     *
     *   descriptor   If `true`, properties will be merged by property descriptor.
     *                Use this option to merge getters or setters, or to preserve
     *                `enumerable`, `configurable`, etc.
     *                (Default `false`)
     *
     *   resolve      Determines which property wins in the case of conflicts.
     *                If `true`, `source` wins. If `false`, the original property
     *                wins. A function of type `resolveFn` may also be passed,
     *                whose return value will decide the result. Any non-undefined
     *                return value will resolve the conflict for that property
     *                (will not continue if `deep`). Returning `undefined` will do
     *                nothing (no merge). Finally, returning the global object
     *                `Sugar` will allow Sugar to handle the merge as normal.
     *                (Default `true`)
     *
     * @callback resolveFn
     *
     *   key        The key of the current iteration.
     *   targetVal  The current value for the key in the target.
     *   sourceVal  The current value for the key in `source`.
     *   target     The target object.
     *   source     The source object.
     *
     * @example
     *
     *   Object.merge({one:1},{two:2})                 -> {one:1,two:2}
     *   Object.merge({one:1},{one:9,two:2})           -> {one:9,two:2}
     *   Object.merge({x:{a:1}},{x:{b:2}},{deep:true}) -> {x:{a:1,b:2}}
     *   Object.merge({a:1},{a:2},{resolve:mergeAdd})  -> {a:3}
     *
     * @param {Object} source
     * @param {ObjectMergeOptions} [options]
     * @callbackParam {string} key
     * @callbackParam {Property} targetVal
     * @callbackParam {Property} sourceVal
     * @callbackParam {Object} target
     * @callbackParam {Object} source
     * @callbackReturns {boolean} resolveFn
     * @option {boolean} [deep]
     * @option {boolean} [hidden]
     * @option {boolean} [descriptor]
     * @option {boolean|resolveFn} [resolve]
     *
     ***/
    'merge': function(target, source, opts) {
      return mergeWithOptions(target, source, opts);
    },

    /***
     * @method add(obj, [options])
     * @returns Object
     * @short Adds properties in `obj` and returns a new object.
     * @extra This method will not modify the original object. See `merge` for options.
     *
     * @example
     *
     *   Object.add({one:1},{two:2})                 -> {one:1,two:2}
     *   Object.add({one:1},{one:9,two:2})           -> {one:9,two:2}
     *   Object.add({x:{a:1}},{x:{b:2}},{deep:true}) -> {x:{a:1,b:2}}
     *   Object.add({a:1},{a:2},{resolve:mergeAdd})  -> {a:3}
     *
     * @param {Object} obj
     * @param {ObjectMergeOptions} [options]
     *
     ***/
    'add': function(obj1, obj2, opts) {
      return mergeWithOptions(clone(obj1), obj2, opts);
    },

    /***
     * @method intersect(obj)
     * @returns Object
     * @short Returns a new object whose properties are those that the object has
     *        in common both with `obj`.
     * @extra If both key and value do not match, then the property will not be included.
     *
     * @example
     *
     *   Object.intersect({a:'a'},{b:'b'}) -> {}
     *   Object.intersect({a:'a'},{a:'b'}) -> {}
     *   Object.intersect({a:'a',b:'b'},{b:'b',z:'z'}) -> {b:'b'}
     *
     * @param {Object} obj
     *
     ***/
    'intersect': function(obj1, obj2) {
      return objectIntersectOrSubtract(obj1, obj2, false);
    },

    /***
     * @method clone([deep] = false)
     * @returns Object
     * @short Creates a clone of the object.
     * @extra Default is a shallow clone, unless [deep] is true.
     *
     * @example
     *
     *   Object.clone({foo:'bar'})       -> creates shallow clone
     *   Object.clone({foo:'bar'}, true) -> creates a deep clone
     *
     * @param {boolean} [deep]
     *
     ***/
    'clone': function(obj, deep) {
      return clone(obj, deep);
    },

    /***
     * @method values()
     * @returns Array
     * @short Returns an array containing the values in the object.
     * @extra Values are in no particular order. Does not include inherited or
     *        non-enumerable properties.
     *
     * @example
     *
     *   Object.values({a:'a',b:'b'}) -> ['a','b']
     *
     ***/
    'values': function(obj) {
      return getValues(obj);
    },

    /***
     * @method isObject()
     * @returns Boolean
     * @short Returns true if the object is a "plain" object.
     * @extra Plain objects do not include instances of classes or "host" objects,
     *        such as Elements, Events, etc.
     *
     * @example
     *
     *   Object.isObject({ broken:'wear' }) -> true
     *
     ***/
    'isObject': function(obj) {
      return isPlainObject(obj);
    },

    /***
     * @method remove(search)
     * @returns Object
     * @short Deletes all properties in the object matching `search`.
     * @extra `search` may be any property or a function of type `searchFn`. This
     *        method will modify the object!. Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   key  The key of the current iteration.
     *   val  The value of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.remove({a:'a',b:'b'}, 'a');           -> {b:'b'}
     *   Object.remove({a:'a',b:'b',z:'z'}, /[a-f]/); -> {z:'z'}
     *
     * @param {Property|searchFn} search
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'remove': function(obj, f) {
      return objectRemove(obj, f);
    },

    /***
     * @method exclude(search)
     * @returns Object
     * @short Returns a new object with all properties matching `search` removed.
     * @extra `search` may be any property or a function of type `searchFn`. This
     *        is a non-destructive version of `remove` and will not modify the
     *        object. Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   key  The key of the current iteration.
     *   val  The value of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.exclude({a:'a',b:'b'}, 'a');           -> {b:'b'}
     *   Object.exclude({a:'a',b:'b',z:'z'}, /[a-f]/); -> {z:'z'}
     *
     * @param {Property|searchFn} search
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'exclude': function(obj, f) {
      return objectExclude(obj, f);
    },

    /***
     * @method select(find)
     * @returns Object
     * @short Builds a new object containing the keys specified in `find`.
     * @extra When `find` is a string, a single key will be selected. Arrays or
     *        objects match multiple keys, and a regex will match keys by regex.
     *
     * @example
     *
     *   Object.select({a:1,b:2}, 'a')           -> {a:1}
     *   Object.select({a:1,b:2}, ['a', 'b'])    -> {a:1,b:2}
     *   Object.select({a:1,b:2}, /[a-z]/)       -> {a:1,b:2}
     *   Object.select({a:1,b:2}, {a:'a',b:'b'}) -> {a:1,b:2}
     *
     * @param {string|RegExp|Array<string>|Object} find
     *
     ***/
    'select': function(obj, f) {
      return objectSelect(obj, f);
    },

    /***
     * @method reject(find)
     * @returns Object
     * @short Builds a new object containing all keys except those in `find`.
     * @extra When `find` is a string, a single key will be rejected. Arrays or
     *        objects match multiple keys, and a regex will match keys by regex.
     *
     * @example
     *
     *   Object.reject({a:1,b:2}, 'a')        -> {b:2}
     *   Object.reject({a:1,b:2}, /[a-z]/)    -> {}
     *   Object.reject({a:1,b:2}, {a:'a'})    -> {b:2}
     *   Object.reject({a:1,b:2}, ['a', 'b']) -> {}
     *
     * @param {string|RegExp|Array<string>|Object} find
     *
     ***/
    'reject': function(obj, f) {
      return objectReject(obj, f);
    }

  });

  defineInstance(sugarObject, {

    /***
     * @method keys()
     * @returns Array
     * @polyfill ES5
     * @short Returns an array containing the keys of all of the non-inherited,
     *        enumerable properties of the object.
     *
     * @example
     *
     *   Object.keys({a:'a',b:'b'}) -> ['a','b']
     *
     ***/
    'keys': function(obj) {
      return getKeys(obj);
    }

  });

  buildClassCheckMethods();

  /***
   * @module Enumerable
   * @description Counting, mapping, and finding methods on both arrays and objects.
   *
   ***/


  function sum(obj, map) {
    var sum = 0;
    enumerateWithMapping(obj, map, function(val) {
      sum += val;
    });
    return sum;
  }

  function average(obj, map) {
    var sum = 0, count = 0;
    enumerateWithMapping(obj, map, function(val) {
      sum += val;
      count++;
    });
    // Prevent divide by 0
    return sum / (count || 1);
  }

  function median(obj, map) {
    var result = [], middle, len;
    enumerateWithMapping(obj, map, function(val) {
      result.push(val);
    });
    len = result.length;
    if (!len) return 0;
    result.sort(function(a, b) {
      // IE7 will throw errors on non-numbers!
      return (a || 0) - (b || 0);
    });
    middle = trunc(len / 2);
    return len % 2 ? result[middle] : (result[middle - 1] + result[middle]) / 2;
  }

  function getMinOrMax(obj, arg1, arg2, max, asObject) {
    var result = [], pushVal, edge, all, map;
    if (isBoolean(arg1)) {
      all = arg1;
      map = arg2;
    } else {
      map = arg1;
    }
    enumerateWithMapping(obj, map, function(val, key) {
      if (isUndefined(val)) {
        throw new TypeError('Cannot compare with undefined');
      }
      pushVal = asObject ? key : obj[key];
      if (val === edge) {
        result.push(pushVal);
      } else if (isUndefined(edge) || (max && val > edge) || (!max && val < edge)) {
        result = [pushVal];
        edge = val;
      }
    });
    return getReducedMinMaxResult(result, obj, all, asObject);
  }

  function getLeastOrMost(obj, arg1, arg2, most, asObject) {
    var group = {}, refs = [], minMaxResult, result, all, map;
    if (isBoolean(arg1)) {
      all = arg1;
      map = arg2;
    } else {
      map = arg1;
    }
    enumerateWithMapping(obj, map, function(val, key) {
      var groupKey = serializeInternal(val, refs);
      var arr = getOwn(group, groupKey) || [];
      arr.push(asObject ? key : obj[key]);
      group[groupKey] = arr;
    });
    minMaxResult = getMinOrMax(group, !!all, 'length', most, true);
    if (all) {
      result = [];
      // Flatten result
      forEachProperty(minMaxResult, function(val) {
        result = result.concat(val);
      });
    } else {
      result = getOwn(group, minMaxResult);
    }
    return getReducedMinMaxResult(result, obj, all, asObject);
  }

  function getReducedMinMaxResult(result, obj, all, asObject) {
    if (asObject && all) {
      // The method has returned an array of keys so use this array
      // to build up the resulting object in the form we want it in.
      return result.reduce(function(o, key) {
        o[key] = obj[key];
        return o;
      }, {});
    } else if (result && !all) {
      result = result[0];
    }
    return result;
  }

  function enumerateWithMapping(obj, map, fn) {
    var arrayIndexes = isArray(obj);
    forEachProperty(obj, function(val, key) {
      if (arrayIndexes) {
        if (!isArrayIndex(key)) {
          return;
        }
        key = +key;
      }
      var mapped = mapWithShortcuts(val, map, obj, [val, key, obj]);
      fn(mapped, key);
    });
  }

  // Flag allowing native array methods to be enhanced
  var ARRAY_ENHANCEMENTS_FLAG = 'enhanceArray';

  // Enhanced map function
  var enhancedMap = buildEnhancedMapping('map');

  // Enhanced matcher methods
  var enhancedFind      = buildEnhancedMatching('find'),
      enhancedSome      = buildEnhancedMatching('some'),
      enhancedEvery     = buildEnhancedMatching('every'),
      enhancedFilter    = buildEnhancedMatching('filter'),
      enhancedFindIndex = buildEnhancedMatching('findIndex');

  function arrayNone() {
    return !enhancedSome.apply(this, arguments);
  }

  function arrayCount(arr, f) {
    if (isUndefined(f)) {
      return arr.length;
    }
    return enhancedFilter.apply(this, arguments).length;
  }

  function buildEnhancedMapping(name) {
    return wrapNativeArrayMethod(name, enhancedMapping);
  }

  function buildEnhancedMatching(name) {
    return wrapNativeArrayMethod(name, enhancedMatching);
  }

  function enhancedMapping(map, context) {
    if (isFunction(map)) {
      return map;
    } else if (map) {
      return function(el, i, arr) {
        return mapWithShortcuts(el, map, context, [el, i, arr]);
      };
    }
  }

  function enhancedMatching(f) {
    var matcher;
    if (isFunction(f)) {
      return f;
    }
    matcher = getMatcher(f);
    return function(el, i, arr) {
      return matcher(el, i, arr);
    };
  }

  function wrapNativeArrayMethod(methodName, wrapper) {
    var nativeFn = Array.prototype[methodName];
    return function(arr, f, context, argsLen) {
      var args = new Array(2);
      assertArgument(argsLen > 0);
      args[0] = wrapper(f, context);
      args[1] = context;
      return nativeFn.apply(arr, args);
    };
  }

  defineInstance(sugarArray, {

    /***
     * @method map(map, [context])
     * @returns New Array
     * @polyfill ES5
     * @short Maps the array to another array whose elements are the values
     *        returned by `map`.
     * @extra [context] is the `this` object. Sugar enhances this method to accept
     *        a string for `map`, which is a shortcut for a function that gets
     *        a property or invokes a function on each element.
     *        Supports `deep properties`.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,3].map(function(n) {
     *     return n * 3;
     *   }); -> [3,6,9]
     *
     *   ['a','aa','aaa'].map('length') -> [1,2,3]
     *   ['A','B','C'].map('toLowerCase') -> ['a','b','c']
     *   users.map('name') -> array of user names
     *
     * @param {string|mapFn} map
     * @param {any} context
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'map': fixArgumentLength(enhancedMap),

    /***
     * @method some(search, [context])
     * @returns Boolean
     * @polyfill ES5
     * @short Returns true if `search` is true for any element in the array.
     * @extra `search` can be an array element or a function of type `searchFn`.
     *        [context] is the `this` object. Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   ['a','b','c'].some(function(n) {
     *     return n == 'a';
     *   });
     *   ['a','b','c'].some(function(n) {
     *     return n == 'd';
     *   });
     *   ['a','b','c'].some('a')    -> true
     *   [{a:2},{b:5}].some({a:2})  -> true
     *   users.some({ name: /^H/ }) -> true if any have a name starting with H
     *
     * @param {ArrayElement|searchFn} search
     * @param {any} context
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'some': fixArgumentLength(enhancedSome),

    /***
     * @method every(search, [context])
     * @returns Boolean
     * @polyfill ES5
     * @short Returns true if `search` is true for all elements of the array.
     * @extra `search` can be an array element or a function of type `searchFn`.
     *        [context] is the `this` object. Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   ['a','a','a'].every(function(n) {
     *     return n == 'a';
     *   });
     *   ['a','a','a'].every('a')   -> true
     *   [{a:2},{a:2}].every({a:2}) -> true
     *   users.every({ name: /^H/ }) -> true if all have a name starting with H
     *
     * @param {ArrayElement|searchFn} search
     * @param {any} context
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'every': fixArgumentLength(enhancedEvery),

    /***
     * @method filter(search, [context])
     * @returns Array
     * @polyfill ES5
     * @short Returns any elements in the array that match `search`.
     * @extra `search` can be an array element or a function of type `searchFn`.
     *        [context] is the `this` object. Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,3].filter(function(n) {
     *     return n > 1;
     *   });
     *   [1,2,2,4].filter(2) -> 2
     *   users.filter({ name: /^H/ }) -> all users with a name starting with H
     *
     * @param {ArrayElement|searchFn} search
     * @param {any} context
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'filter': fixArgumentLength(enhancedFilter),

    /***
     * @method find(search, [context])
     * @returns Mixed
     * @polyfill ES6
     * @short Returns the first element in the array that matches `search`.
     * @extra `search` can be an array element or a function of type `searchFn`.
     *        Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   users.find(function(user) {
     *     return user.name = 'Harry';
     *   }); -> harry!
     *
     *   users.find({ name: 'Harry' }); -> harry!
     *   users.find({ name: /^[A-H]/ });  -> First user with name starting with A-H
     *   users.find({ titles: ['Ms', 'Dr'] }); -> not harry!
     *
     * @param {ArrayElement|searchFn} search
     * @param {any} context
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'find': fixArgumentLength(enhancedFind),

    /***
     * @method findIndex(search, [context])
     * @returns Number
     * @polyfill ES6
     * @short Returns the index of the first element in the array that matches
     *        `search`, or `-1` if none.
     * @extra `search` can be an array element or a function of type `searchFn`.
     *        [context] is the `this` object. Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,3,4].findIndex(function(n) {
     *     return n % 2 == 0;
     *   }); -> 1
     *   ['a','b','c'].findIndex('c');        -> 2
     *   ['cuba','japan','canada'].find(/^c/) -> 0
     *
     * @param {ArrayElement|searchFn} search
     * @param {any} context
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'findIndex': fixArgumentLength(enhancedFindIndex)

  }, [ENHANCEMENTS_FLAG, ARRAY_ENHANCEMENTS_FLAG]);

  defineInstance(sugarArray, {

    /***
     * @method none(search, [context])
     *
     * @returns Boolean
     * @short Returns true if none of the elements in the array match `search`.
     * @extra `search` can be an array element or a function of type `searchFn`.
     *        [context] is the `this` object. Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,3].none(5)         -> true
     *   ['a','b','c'].none(/b/) -> false
     *   users.none(function(user) {
     *     return user.name == 'Wolverine';
     *   }); -> probably true
     *   users.none({ name: 'Wolverine' }); -> same as above
     *
     * @param {ArrayElement|searchFn} search
     * @param {any} context
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'none': fixArgumentLength(arrayNone),

    /***
     * @method count(search, [context])
     * @returns Number
     * @short Counts all elements in the array that match `search`.
     * @extra `search` can be an element or a function of type `searchFn`.
     *        Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   ['a','b','a'].count('a') -> 2
     *   ['a','b','c'].count(/b/) -> 1
     *   users.count(function(user) {
     *     return user.age > 30;
     *   }); -> number of users older than 30
     *
     * @param {ArrayElement|searchFn} search
     * @param {any} context
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'count': fixArgumentLength(arrayCount),

    /***
     * @method min([all] = false, [map])
     * @returns Mixed
     * @short Returns the element in the array with the lowest value.
     * @extra [map] can be passed in place of [all], and is a function of type
     *        `mapFn` that maps the value to be checked or a string acting as a
     *        shortcut. If [all] is true, multiple elements will be returned.
     *        Supports `deep properties`.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,3].min()                          -> 1
     *   ['fee','fo','fum'].min('length')       -> 'fo'
     *   ['fee','fo','fum'].min(true, 'length') -> ['fo']
     *   users.min('age')                       -> youngest guy!
     *
     *   ['fee','fo','fum'].min(true, function(n) {
     *     return n.length;
     *   }); -> ['fo']
     *
     * @signature min([map])
     * @param {string|mapFn} map
     * @param {boolean} all
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'min': function(arr, all, map) {
      return getMinOrMax(arr, all, map);
    },

    /***
     * @method max([all] = false, [map])
     * @returns Mixed
     * @short Returns the element in the array with the greatest value.
     * @extra [map] can be passed in place of [all], and is a function of type
     *        `mapFn` that maps the value to be checked or a string acting as a
     *        shortcut. If [all] is true, multiple elements will be returned.
     *        Supports `deep properties`.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,3].max()                          -> 3
     *   ['fee','fo','fum'].max('length')       -> 'fee'
     *   ['fee','fo','fum'].max(true, 'length') -> ['fee','fum']
     *   users.max('age')                       -> oldest guy!
     *
     *   ['fee','fo','fum'].max(true, function(n) {
     *     return n.length;
     *   }); -> ['fee', 'fum']
     *
     * @signature max([map])
     * @param {string|mapFn} map
     * @param {boolean} all
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'max': function(arr, all, map) {
      return getMinOrMax(arr, all, map, true);
    },

    /***
     * @method least([all] = false, [map])
     * @returns Array
     * @short Returns the elements in the array with the least commonly occuring value.
     * @extra [map] can be passed in place of [all], and is a function of type
     *        `mapFn` that maps the value to be checked or a string acting as a
     *        shortcut. If [all] is true, will return multiple values in an array.
     *        Supports `deep properties`.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [3,2,2].least() -> 3
     *   ['fe','fo','fum'].least(true, 'length') -> ['fum']
     *   users.least('profile.type')             -> (user with least commonly occurring type)
     *   users.least(true, 'profile.type')       -> (users with least commonly occurring type)
     *
     * @signature least([map])
     * @param {string|mapFn} map
     * @param {boolean} all
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'least': function(arr, all, map) {
      return getLeastOrMost(arr, all, map);
    },

    /***
     * @method most([all] = false, [map])
     * @returns Array
     * @short Returns the elements in the array with the most commonly occuring value.
     * @extra [map] can be passed in place of [all], and is a function of type
     *        `mapFn` that maps the value to be checked or a string acting as a
     *        shortcut. If [all] is true, will return multiple values in an array.
     *        Supports `deep properties`.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [3,2,2].most(2) -> 2
     *   ['fe','fo','fum'].most(true, 'length') -> ['fe','fo']
     *   users.most('profile.type')             -> (user with most commonly occurring type)
     *   users.most(true, 'profile.type')       -> (users with most commonly occurring type)
     *
     * @signature most([map])
     * @param {string|mapFn} map
     * @param {boolean} all
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'most': function(arr, all, map) {
      return getLeastOrMost(arr, all, map, true);
    },

    /***
     * @method sum([map])
     * @returns Number
     * @short Sums all values in the array.
     * @extra [map] can be a function of type `mapFn` that maps the value to be
     *        summed or a string acting as a shortcut.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,2].sum() -> 5
     *   users.sum(function(user) {
     *     return user.votes;
     *   }); -> total votes!
     *   users.sum('votes') -> total votes!
     *
     * @param {string|mapFn} map
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'sum': function(arr, map) {
      return sum(arr, map);
    },

    /***
     * @method average([map])
     * @returns Number
     * @short Gets the mean average for all values in the array.
     * @extra [map] can be a function of type `mapFn` that maps the value to be
     *        averaged or a string acting as a shortcut. Supports `deep properties`.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,3,4].average() -> 2
     *   users.average(function(user) {
     *     return user.age;
     *   }); -> average user age
     *   users.average('age') -> average user age
     *   users.average('currencies.usd.balance') -> average USD balance
     *
     * @param {string|mapFn} map
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'average': function(arr, map) {
      return average(arr, map);
    },

    /***
     * @method median([map])
     * @returns Number
     * @short Gets the median average for all values in the array.
     * @extra [map] can be a function of type `mapFn` that maps the value to be
     *        averaged or a string acting as a shortcut.
     *
     * @callback mapFn
     *
     *   el   The element of the current iteration.
     *   i    The index of the current iteration.
     *   arr  A reference to the array.
     *
     * @example
     *
     *   [1,2,2].median() -> 2
     *   [{a:1},{a:2},{a:2}].median('a') -> 2
     *   users.median('age') -> median user age
     *   users.median('currencies.usd.balance') -> median USD balance
     *
     * @param {string|mapFn} map
     * @callbackParam {ArrayElement} el
     * @callbackParam {number} i
     * @callbackParam {Array} arr
     * @callbackReturns {NewArrayElement} mapFn
     *
     ***/
    'median': function(arr, map) {
      return median(arr, map);
    }

  });

  // Object matchers
  var objectSome  = wrapObjectMatcher('some'),
      objectFind  = wrapObjectMatcher('find'),
      objectEvery = wrapObjectMatcher('every');

  function objectForEach(obj, fn) {
    assertCallable(fn);
    forEachProperty(obj, function(val, key) {
      fn(val, key, obj);
    });
    return obj;
  }

  function objectMap(obj, map) {
    var result = {};
    forEachProperty(obj, function(val, key) {
      result[key] = mapWithShortcuts(val, map, obj, [val, key, obj]);
    });
    return result;
  }

  function objectReduce(obj, fn, acc) {
    var init = isDefined(acc);
    forEachProperty(obj, function(val, key) {
      if (!init) {
        acc = val;
        init = true;
        return;
      }
      acc = fn(acc, val, key, obj);
    });
    return acc;
  }

  function objectNone(obj, f) {
    return !objectSome(obj, f);
  }

  function objectFilter(obj, f) {
    var matcher = getMatcher(f), result = {};
    forEachProperty(obj, function(val, key) {
      if (matcher(val, key, obj)) {
        result[key] = val;
      }
    });
    return result;
  }

  function wrapObjectMatcher(name) {
    var nativeFn = Array.prototype[name];
    return function(obj, f) {
      var matcher = getMatcher(f);
      return nativeFn.call(getKeys(obj), function(key) {
        return matcher(obj[key], key, obj);
      });
    };
  }

  defineInstanceAndStatic(sugarObject, {

    /***
     * @method forEach(eachFn)
     * @returns Object
     * @short Runs `eachFn` against each property in the object.
     * @extra Does not iterate over inherited or non-enumerable properties.
     *
     * @callback eachFn
     *
     *   val  The value of the current iteration.
     *   key  The key of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.forEach({a:'b'}, function(val, key) {
     *     // val = 'b', key = a
     *   });
     *
     * @param {eachFn} eachFn
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     *
     ***/
    'forEach': function(obj, eachFn) {
      return objectForEach(obj, eachFn);
    },

    /***
     * @method map(map)
     * @returns Object
     * @short Maps the object to another object whose properties are the values
     *        returned by `map`.
     * @extra `map` can be a function of type `mapFn` or a string that acts as a
     *        shortcut and gets a property or invokes a function on each element.
     *        Supports `deep properties`.
     *
     * @callback mapFn
     *
     *   val  The value of the current property.
     *   key  The key of the current property.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   data.map(function(val, key) {
     *     return key;
     *   }); -> {a:'b'}
     *   users.map('age');
     *
     * @param {string|mapFn} map
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {NewProperty} mapFn
     *
     ***/
    'map': function(obj, map) {
      return objectMap(obj, map);
    },

    /***
     * @method some(search)
     * @returns Boolean
     * @short Returns true if `search` is true for any property in the object.
     * @extra `search` can be any property or a function of type `searchFn`.
     *        Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   val  The value of the current iteration.
     *   key  The key of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.some({a:1,b:2}, function(val) {
     *     return val == 1;
     *   }); -> true
     *   Object.some({a:1,b:2}, 1); -> true
     *
     * @param {Property|searchFn} search
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'some': objectSome,

    /***
     * @method every(search)
     * @returns Boolean
     * @short Returns true if `search` is true for all properties in the object.
     * @extra `search` can be any property or a function of type `searchFn`.
     *        Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   val  The value of the current iteration.
     *   key  The key of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.every({a:1,b:2}, function(val) {
     *     return val > 0;
     *   }); -> true
     *   Object.every({a:'a',b:'b'}, /[a-z]/); -> true
     *
     * @param {Property|searchFn} search
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'every': objectEvery,

    /***
     * @method filter(search)
     * @returns Array
     * @short Returns a new object with properties that match `search`.
     * @extra `search` can be any property or a function of type `searchFn`.
     *        Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   val  The value of the current iteration.
     *   key  The key of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.filter({a:1,b:2}, function(val) {
     *     return val == 1;
     *   }); -> {a:1}
     *   Object.filter({a:'a',z:'z'}, /[a-f]/); -> {a:'a'}
     *   Object.filter(usersByName, /^H/); -> all users with names starting with H
     *
     * @param {Property|searchFn} search
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'filter': function(obj, f) {
      return objectFilter(obj, f);
    },

    /***
     * @method reduce(reduceFn, [init])
     * @returns Mixed
     * @short Reduces the object to a single result.
     * @extra This operation is sometimes called "accumulation", as it takes the
     *        result of the last iteration of `fn` and passes it as the first
     *        argument to the next iteration, "accumulating" that value as it goes.
     *        The return value of this method will be the return value of the final
     *        iteration of `fn`. If [init] is passed, it will be the initial
     *        "accumulator" (the first argument). If [init] is not passed, then a
     *        property of the object will be used instead and `fn` will not be
     *        called for that property. Note that object properties have no order,
     *        and this may lead to bugs (for example if performing division or
     *        subtraction operations on a value). If order is important, use an
     *        array instead!
     *
     * @callback reduceFn
     *
     *   acc  The "accumulator", either [init], the result of the last iteration
     *        of `fn`, or a property of `obj`.
     *   val  The value of the current property called for `fn`.
     *   key  The key of the current property called for `fn`.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.reduce({a:2,b:4}, function(a, b) {
     *     return a * b;
     *   }); -> 8
     *
     *   Object.reduce({a:2,b:4}, function(a, b) {
     *     return a * b;
     *   }, 10); -> 80
     *
     *
     * @param {reduceFn} reduceFn
     * @param {any} [init]
     * @callbackParam {Property} acc
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     *
     ***/
    'reduce': function(obj, fn, init) {
      return objectReduce(obj, fn, init);
    },

    /***
     * @method find(search)
     * @returns Boolean
     * @short Returns the first key whose value matches `search`.
     * @extra `search` can be any property or a function of type `searchFn`.
     *        Implements `enhanced matching`. Note that "first" is
     *        implementation-dependent. If order is important an array should be
     *        used instead.
     *
     * @callback searchFn
     *
     *   val  The value of the current iteration.
     *   key  The key of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.find({a:1,b:2}, function(val) {
     *     return val == 2;
     *   }); -> 'b'
     *   Object.find({a:'a',b:'b'}, /[a-z]/); -> 'a'
     *
     * @param {Property|searchFn} search
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'find': objectFind,

    /***
     * @method none(search)
     * @returns Boolean
     * @short Returns true if none of the properties in the object match `search`.
     * @extra `search` can be any property or a function of type `searchFn`.
     *        Implements `enhanced matching`.
     *
     * @callback searchFn
     *
     *   val  The value of the current iteration.
     *   key  The key of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.none({a:1,b:2}, 3); -> true
     *   Object.none(usersByName, function(user) {
     *     return user.name == 'Wolverine';
     *   }); -> probably true
     *
     * @param {Property|searchFn} search
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {boolean} searchFn
     *
     ***/
    'none': function(obj, f) {
      return objectNone(obj, f);
    },

    /***
     * @method min([all] = false, [map])
     * @returns Mixed
     * @short Returns the key of the property in the object with the lowest value.
     * @extra If [all] is true, will return an object with all properties in the
     *        object with the lowest value. [map] can be passed in place of [all]
     *        and is a function of type `mapFn` that maps the value to be checked
     *        or a string acting as a shortcut.
     *
     * @callback mapFn
     *
     *   val  The value of the current iteration.
     *   key  The key of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.min({a:1,b:2,c:3})                    -> 'a'
     *   Object.min({a:'aaa',b:'bb',c:'c'}, 'length') -> 'c'
     *   Object.min({a:1,b:1,c:3}, true)              -> {a:1,b:1}
     *
     * @signature min([map])
     * @param {string|mapFn} map
     * @param {boolean} [all]
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {NewProperty} mapFn
     *
     ***/
    'min': function(obj, all, map) {
      return getMinOrMax(obj, all, map, false, true);
    },

    /***
     * @method max([all] = false, [map])
     * @returns Mixed
     * @short Returns the key of the property in the object with the highest value.
     * @extra If [all] is true, will return an object with all properties in the
     *        object with the highest value. [map] can be passed in place of [all]
     *        and is a function of type `mapFn` that maps the value to be checked
     *        or a string acting as a shortcut.
     *
     * @callback mapFn
     *
     *   val  The value of the current iteration.
     *   key  The key of the current iteration.
     *   obj  A reference to the object.
     *
     * @example
     *
     *   Object.max({a:1,b:2,c:3})                    -> 'c'
     *   Object.max({a:'aaa',b:'bb',c:'c'}, 'length') -> 'a'
     *   Object.max({a:1,b:3,c:3}, true)              -> {b:3,c:3}
     *
     * @signature max([map])
     * @param {string|mapFn} map
     * @param {boolean} [all]
     * @callbackParam {Property} val
     * @callbackParam {string} key
     * @callbackParam {Object} obj
     * @callbackReturns {NewProperty} mapFn
     *
     ***/
    'max': function(obj, all, map) {
      return getMinOrMax(obj, all, map, true, true);
    }

  });

  /***
   * @module Number
   * @description Number formatting, precision rounding, Math aliases, and more.
   *
   ***/


  var NUMBER_OPTIONS = {
    'decimal': HALF_WIDTH_PERIOD,
    'thousands': HALF_WIDTH_COMMA
  };

  /***
   * @method getOption(name)
   * @returns Mixed
   * @accessor
   * @short Gets an option used internally by Number.
   * @example
   *
   *   Sugar.Number.getOption('thousands');
   *
   * @param {string} name
   *
   ***
   * @method setOption(name, value)
   * @accessor
   * @short Sets an option used internally by Number.
   * @extra If `value` is `null`, the default value will be restored.
   * @options
   *
   *   decimal     A string used as the decimal marker by `format`, `abbr`,
   *               `metric`, and `bytes`. Default is `.`.
   *
   *   thousands   A string used as the thousands marker by `format`, `abbr`,
   *               `metric`, and `bytes`. Default is `,`.
   *
   *
   * @example
   *
   *   Sugar.Number.setOption('decimal', ',');
   *   Sugar.Number.setOption('thousands', ' ');
   *
   * @signature setOption(options)
   * @param {NumberOptions} options
   * @param {string} name
   * @param {any} value
   * @option {string} decimal
   * @option {string} thousands
   *
   ***/
  var _numberOptions = defineOptionsAccessor(sugarNumber, NUMBER_OPTIONS);

  function createRoundingFunction(fn) {
    return function(n, precision) {
      return precision ? withPrecision(n, precision, fn) : fn(n);
    };
  }

  defineInstance(sugarNumber, {

    /***
     * @method round([precision] = 0)
     * @returns Number
     * @short Shortcut for `Math.round` that also allows a `precision`.
     *
     * @example
     *
     *   (3.241).round()  -> 3
     *   (-3.841).round() -> -4
     *   (3.241).round(2) -> 3.24
     *   (3748).round(-2) -> 3800
     *
     * @param {number} [precision]
     *
     ***/
    'round': createRoundingFunction(round),

    /***
     * @method ceil([precision] = 0)
     * @returns Number
     * @short Shortcut for `Math.ceil` that also allows a `precision`.
     *
     * @example
     *
     *   (3.241).ceil()  -> 4
     *   (-3.241).ceil() -> -3
     *   (3.241).ceil(2) -> 3.25
     *   (3748).ceil(-2) -> 3800
     *
     * @param {number} [precision]
     *
     ***/
    'ceil': createRoundingFunction(ceil),

    /***
     * @method floor([precision] = 0)
     * @returns Number
     * @short Shortcut for `Math.floor` that also allows a `precision`.
     *
     * @example
     *
     *   (3.241).floor()  -> 3
     *   (-3.841).floor() -> -4
     *   (3.241).floor(2) -> 3.24
     *   (3748).floor(-2) -> 3700
     *
     * @param {number} [precision]
     *
     ***/
    'floor': createRoundingFunction(floor)

  });

  /***
   * @module Function
   * @description Lazy, throttled, and memoized functions, delayed functions and
   *              handling of timers, argument currying.
   *
   ***/


  var _lock     = privatePropertyAccessor('lock');

  var _partial  = privatePropertyAccessor('partial');

  var createInstanceFromPrototype = Object.create || function(prototype) {
    var ctor = function() {};
    ctor.prototype = prototype;
    return new ctor;
  };

  defineInstanceWithArguments(sugarFunction, {

    /***
     * @method partial([arg1], [arg2], ...)
     * @returns Function
     * @short Returns a new version of the function which has part of its arguments
     *        pre-emptively filled in, also known as "currying".
     * @extra `undefined` can be passed as any argument, and is a placeholder that
     *        will be replaced with arguments passed when the function is executed.
     *        This allows currying of arguments even when they occur toward the end
     *        of an argument list (the example demonstrates this more clearly).
     *
     * @example
     *
     *   logArgs.partial(undefined, 'b')('a') -> logs a, b
     *
     * @param {any} [arg1]
     * @param {any} [arg2]
     *
     ***/
    'partial': function(fn, curriedArgs) {
      var curriedLen = curriedArgs.length;
      var partialFn = function() {
        var argIndex = 0, applyArgs = [], self = this, lock = _lock(partialFn), result, i;
        for (i = 0; i < curriedLen; i++) {
          var arg = curriedArgs[i];
          if (isDefined(arg)) {
            applyArgs[i] = arg;
          } else {
            applyArgs[i] = arguments[argIndex++];
          }
        }
        for (i = argIndex; i < arguments.length; i++) {
          applyArgs.push(arguments[i]);
        }
        if (lock === null) {
          lock = curriedLen;
        }
        if (isNumber(lock)) {
          applyArgs.length = min(applyArgs.length, lock);
        }
        // If the bound "this" object is an instance of the partialed
        // function, then "new" was used, so preserve the prototype
        // so that constructor functions can also be partialed.
        if (self instanceof partialFn) {
          self = createInstanceFromPrototype(fn.prototype);
          result = fn.apply(self, applyArgs);
          // An explicit return value is allowed from constructors
          // as long as they are of "object" type, so return the
          // correct result here accordingly.
          return isObjectType(result) ? result : self;
        }
        return fn.apply(self, applyArgs);
      };
      _partial(partialFn, true);
      return partialFn;
    }

  });

}).call(this);

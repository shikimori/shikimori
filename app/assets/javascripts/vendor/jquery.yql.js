/*
 * jQuery YQL plugin
 *
 * Copyright (c) 2010 Gabriel FalcÃ£o
 * Copyright (c) 2010 Lincoln de Sousa
 * licensed under MIT license.
 *
 * http://github.com/gabrielfalcao/jquery-yql/raw/master/license.txt
 *
 * Version: 0.3.0
 */

(function($){
     $.extend(
         {
             _prepareYQLQuery: function (query, params) {
                 $.each(
                     params, function (key) {
                         var name = "#{" + key + "}";
                         var value = $.trim(this);
                         if (!value.match(/^[0-9]+$/)) {
                             value = '"' + value + '"';
                         }
                         while (query.search(name) > -1) {
                             query = query.replace(name, value);
                         }

                         var name = "@" + key;
                         var value = $.trim(this);
                         if (!value.match(/^[0-9]+$/)) {
                             value = '"' + value + '"';
                         }
                         while (query.search(name) > -1) {
                             query = query.replace(name, value);
                         }

                     }
                 );
                 return query;
             },
             yql: function (query) {
                 var $self = this;
                 var successCallback = null;
                 var errorCallback = null;

                 if (typeof arguments[1] == 'object') {
                     query = $self._prepareYQLQuery(query, arguments[1]);
                     successCallback = arguments[2];
                     errorCallback = arguments[3];
                 } else if (typeof arguments[1] == 'function') {
                     successCallback = arguments[1];
                     errorCallback = arguments[2];
                 }

                 var doAsynchronously = successCallback != null;
                 var yqlJson = {
                     url: location.protocol + "//query.yahooapis.com/v1/public/yql",
                     dataType: "jsonp",
                     success: successCallback,
                     error: errorCallback,
                     async: doAsynchronously,
                     data: {
                         q: query,
                         format: "json",
                         env: 'store://datatables.org/alltableswithkeys',
                         callback: "?"
                     }
                 }

                 $.ajax(yqlJson);
                 return $self.toReturn;
             },
             yqlJSON: function(url, successCallback, errorCallback) {
                 return $.yql("SELECT * FROM json WHERE url=#{url}", {url: url}, function(data) {
                    successCallback(data.query.results && data.query.results.json);
                 }, errorCallback);
             },
             yqlXML: function(url, successCallback, errorCallback) {
                 return $.yql("SELECT * FROM xml WHERE url=#{url}", {url: url}, function(data) {
                     successCallback(data.query.results);
                 }, errorCallback);
             }
         }
     );
 })(jQuery);

$(document).ajaxSend(function(e, xhr, options) {
  var token = $("meta[name='csrf-token']").attr("content");
  xhr.setRequestHeader('X-CSRF-Token', token);

  if ('faye_loader' in window && faye_loader.id()) {
    xhr.setRequestHeader('X-Faye-Token', faye_loader.id());
  }
});

jQuery(function ($) {
    var csrf_token = $('meta[name=csrf-token]').attr('content'),
        csrf_param = $('meta[name=csrf-param]').attr('content');

    $.fn.extend({
        /**
         * Triggers a custom event on an element and returns the event result
         * this is used to get around not being able to ensure callbacks are placed
         * at the end of the chain.
         *
         * TODO: deprecate with jQuery 1.4.2 release, in favor of subscribing to our
         *       own events and placing ourselves at the end of the chain.
         */
        triggerAndReturn: function (name, data) {
            var event = new $.Event(name);
            this.trigger(event, data);

            return event.result !== false;
        },

        /**
         * Handles execution of remote calls firing overridable events along the way
         */
        callRemote: function () {
            var $this = $(this);
            var should_lock = is_form = $this.is('form');
            var el      = this,
                method  = el.data('method') || el.attr('method') || 'GET',
                url     = el.data('action') || el.attr('action') || el.attr('href'),
                dataType  = el.data('type')  || 'script';

            // иногда бывает надо отключить функционал
            if ($this.data('disabled')) {
              return;
            }

            if (url === undefined) {
              throw "No URL specified for remote call (action or href must be present).";
            } else {
                if (el.triggerAndReturn('ajax:before')) {
                    // шлём только один запрос
                    if (should_lock && $this.data('ajax:locked')) {
                      return;
                    }
                    $this.data('ajax:locked', true);
                    var data = is_form ? el.serializeArray() : ($this.data('form') || []);
                    $.ajax({
                        url: url,
                        data: data,
                        dataType: dataType,
                        type: method.toUpperCase(),
                        beforeSend: function (xhr) {
                            $.cursorMessage();
                            el.trigger('ajax:loading', {xhr: xhr, ajax: this});
                            if (xhr.statusText == 'abort') {
                              $this.data('ajax:locked', false);
                              $.hideCursorMessage();
                            }
                        },
                        success: function (data, status, xhr) {
                            $this.data('ajax:locked', false);
                            if (!_.isString(data) && 'notice' in data && data.notice) {
                                $.flash({notice: data.notice});
                            }
                            el.trigger('ajax:success', [data, status, xhr]);
                            $.hideCursorMessage();
                        },
                        complete: function (xhr) {
                            $this.data('ajax:locked', false);
                            el.trigger('ajax:complete', xhr);
                        },
                        error: function (xhr, status, error) {
                            $this.data('ajax:locked', false);
                            if (xhr.responseText.match(/invalid/)) {// || xhr.responseText.match(/unauthenticated/)) {
                                $.flash({alert: 'Неверный логин или пароль'});
                            } else if (xhr.status == 401) {
                                $.flash({alert: 'Вы не авторизованы'});
                                $('#sign_in').trigger('click');
                            } else if (xhr.status == 403) {
                                $.flash({alert: (xhr.responseText != 'Forbidden' ? xhr.responseText : 'У вас нет прав для данного действия')});
                            } else if (xhr.status == 500) {
                                $.flash({alert: 'Пожалуста, повторите попытку позже'});
                            } else {
                                try {
                                  var errors = JSON.parse(xhr.responseText);
                                } catch(e) {
                                  var errors = {};
                                }
                                if ('errors' in errors) {
                                  errors = errors.errors;
                                }
                                if (_.size(errors)) {
                                    if (_.isArray(errors)) {
                                      $.flash({alert: errors.join('<br />')});
                                    } else {
                                      var text = _.map(errors, function(v, k) {
                                        if ((k == 'nickname' || k == 'email') && v == 'уже существует') {
                                          v = 'уже используется другим пользователем';
                                        }
                                        if (k == 'base') {
                                          return v;
                                        } else {
                                          return "<strong>" + (k in I18N ? I18N[k] : k) + "</strong> " + v;
                                        }
                                      }).join('<br />');

                                      $.flash({alert: text});
                                    }
                                } else {
                                    $.flash({alert: 'Пожалуста, повторите попытку позже'});
                                }
                            }
                            el.trigger('ajax:failure', [xhr, status, error]);
                            $.hideCursorMessage();
                        }
                    });
                }

                el.trigger('ajax:after');
            }
        }
    });

    /**
     * remote handlers
     */
    $('a[data-method]:not([data-remote]),span[data-method]:not([data-remote])').live('click', function (e){
        var link = $(this),
            href = link.attr('href') || link.data('action'),
            method = link.attr('data-method'),
            form = $('<form method="post" action="'+href+'"></form>'),
            metadata_input = '<input name="_method" value="'+method+'" type="hidden" />';

        if (link.attr('data-confirm') && !confirm(link.attr('data-confirm'))) {
            e.stopImmediatePropagation();
            return false;
        }

        if (csrf_param != null && csrf_token != null) {
          metadata_input += '<input name="'+csrf_param+'" value="'+csrf_token+'" type="hidden" />';
        }

        form.hide()
            .append(metadata_input)
            .appendTo('body');

        e.preventDefault();
        e.stopImmediatePropagation();
        form.submit();
    });


    /**
     *  confirmation handler
     */
    $('a[data-confirm]:not([data-remote]),input[data-confirm]').live('click', function () {
        var el = $(this);
        if (el.triggerAndReturn('confirm')) {
            if (!confirm(el.attr('data-confirm'))) {
                return false;
            }
        }
    });


    /**
     * remote handlers
     */
    $('form[data-remote]').live('submit', function (e) {
        $(this).callRemote();
        e.preventDefault();
    });

    $('a[data-remote],input[data-remote],span[data-remote],li[data-remote],button[data-remote],tr[data-remote]').live('click', function (e) {
        if ('in_new_tab' in window && in_new_tab(e)) {
          return;
        }
        var $this = $(this);
        if ($this.attr('data-confirm') && !confirm($this.attr('data-confirm'))) {
            return false;
        }
        $this.callRemote();
        e.preventDefault();
    });

    /**
     * disable-with handlers
     */
    //var disable_with_input_selector           = 'input[data-disable-with]';
    //var disable_with_form_remote_selector     = 'form[data-remote]:has('       + disable_with_input_selector + ')';
    //var disable_with_form_not_remote_selector = 'form:not([data-remote]):has(' + disable_with_input_selector + ')';

    //var disable_with_input_function = function () {
        //$(this).find(disable_with_input_selector).each(function () {
            //var input = $(this);
            //input.data('enable-with', input.val())
                //.attr('value', input.attr('data-disable-with'))
                //.attr('disabled', 'disabled');
        //});
    //};

    //$(disable_with_form_remote_selector).live('ajax:before', disable_with_input_function);
    //$(disable_with_form_not_remote_selector).live('submit', disable_with_input_function);

    //$(disable_with_form_remote_selector).live('ajax:complete', function () {
        //$(this).find(disable_with_input_selector).each(function () {
            //var input = $(this);
            //input.removeAttr('disabled')
                 //.val(input.data('enable-with'));
        //});
    //});
});

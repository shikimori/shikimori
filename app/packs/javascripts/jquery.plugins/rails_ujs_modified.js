import { flash } from 'shiki-utils';
import inNewTab from '@/utils/in_new_tab';

/* eslint-disable */
$(document).ajaxSend((e, xhr, options) => {
  const token = $('meta[name=\'csrf-token\']').attr('content');
  xhr.setRequestHeader('X-CSRF-Token', token);

  if ('SHIKI_FAYE_LOADER' in window && SHIKI_FAYE_LOADER.id) {
    xhr.setRequestHeader('X-Faye-Token', SHIKI_FAYE_LOADER.id);
  }
});

jQuery($ => {
  const csrf_token = $('meta[name=csrf-token]').attr('content');
  const csrf_param = $('meta[name=csrf-param]').attr('content');

  $.fn.extend({
        /**
         * Triggers a custom event on an element and returns the event result
         * this is used to get around not being able to ensure callbacks are placed
         * at the end of the chain.
         *
         * TODO: deprecate with jQuery 1.4.2 release, in favor of subscribing to our
         *       own events and placing ourselves at the end of the chain.
         */
    triggerAndReturn(name, data) {
      const event = new $.Event(name);
      this.trigger(event, data);

      return event.result !== false;
    },

        /**
         * Handles execution of remote calls firing overridable events along the way
         */
    callRemote(originalTarget) {
      const $this = $(this);
      const is_form = $this.is('form');
      const should_lock = is_form;
      const el = this;

            // иногда бывает надо отключить функционал
      if ($this.data('disabled')) { return false; }
      if (el.triggerAndReturn('ajax:before')) {
                // шлём только один запрос
        if (should_lock && $this.data('ajax:locked')) { return; }
        $this.data('ajax:locked', true);
        const data = is_form ? el.serializeArray() : ($this.data('form') || []);

        // next 5 lines were moved from before "if ($this.data('disabled')) {" line
        const method = el.data('method') || el.attr('method') || 'GET';
        const url = el.data('action') || el.attr('action') || el.attr('href');
        const dataType = el.data('type') || 'script';

        if (url === undefined) { return false; }

        $.ajax({
          url,
          data,
          dataType,
          type: method.toUpperCase(),
          beforeSend(xhr) {
            el.trigger('ajax:loading', { xhr, ajax: this });
            if (xhr.statusText == 'abort') {
              $this.data('ajax:locked', false);
            }
          },
          success(data, status, xhr) {
            $this.data('ajax:locked', false);
            if (!Object.isString(data) && data && 'notice' in data && data.notice) {
              flash.notice(data.notice);
            }
            el.trigger('ajax:success', [data, status, xhr]);
          },
          complete(xhr) {
            $this.data('ajax:locked', false);
            el.trigger('ajax:complete', xhr);
          },
          error(xhr, status, error) {
            $this.data('ajax:locked', false);
            if (xhr.responseText && xhr.responseText.match(/invalid/)) { // || xhr.responseText.match(/unauthenticated/)) {
              flash.error(I18n.t('frontend.lib.rails_ujs_modified.invalid_login_or_password'));
            } else if (xhr.status == 403) {
              try {
                var errors = JSON.parse(xhr.responseText);
              } catch (e) {
                var errors = {};
              }
              if (Object.isObject(errors) && errors.message) {
                flash.error(errors.message);
              } else {
                flash.error(xhr.responseText != 'Forbidden' ?
                  xhr.responseText :
                  I18n.t('frontend.lib.rails_ujs_modified.you_are_not_authorized')
                );
              }
            } else if (xhr.status == 500) {
              flash.error(I18n.t('frontend.lib.please_try_again_later'));
            } else {
              try {
                var errors = JSON.parse(xhr.responseText);
              } catch (e) {
                var errors = {};
              }
              if ('errors' in errors) {
                errors = errors.errors;
              } else if ('error' in errors) {
                errors = [errors.error];
              }
              if (Object.size(errors)) {
                if (Object.isArray(errors)) {
                  flash.error(errors.join('<br />'));
                } else {
                  const text = errors.map((v, k) => {
                    if (k == 'base') {
                      return v;
                    }
                    return '<strong>' +
                                        I18n.t('frontend.lib.rails_ujs_modified.' + k, { defaultValue: k }) +
                                          '</strong> ' +
                                          (Object.isArray(v) ? v.join(', ') : v);
                  }).join('<br />');

                  flash.error(text);
                }
              } else {
                flash.error(I18n.t('frontend.lib.please_try_again_later'));
              }
            }
            el.trigger('ajax:failure', [xhr, status, error]);
          }
        });
      } else {
        return false;
      }

      el.trigger('ajax:after');
    }
  });

    /**
     * remote handlers
     */
  $(document).on('click', 'a[data-method]:not([data-remote]),span[data-method]:not([data-remote])', function (e) {
    const link = $(this);


    const href = link.attr('href') || link.data('action');


    const method = link.attr('data-method');


    const form = $('<form method="post" action="' + href + '"></form>');


    let metadata_input = '<input name="_method" value="' + method + '" type="hidden" />';

    if (link.attr('data-confirm') && !confirm(link.attr('data-confirm'))) {
      e.stopImmediatePropagation();
      return false;
    }

    if (csrf_param != null && csrf_token != null) {
      metadata_input += '<input name="' + csrf_param + '" value="' + csrf_token + '" type="hidden" />';
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
  $(document).on('click', 'a[data-confirm]:not([data-remote]),input[data-confirm]', function () {
    const el = $(this);
    if (el.triggerAndReturn('confirm')) {
      if (!confirm(el.attr('data-confirm'))) {
        return false;
      }
    }
  });


    /**
     * remote handlers
     */
  $(document).on('submit', 'form[data-remote]', function (e) {
    $(this).callRemote();
    e.preventDefault();
  });

  $(document).on('click', 'a[data-remote],input[data-remote],span[data-remote],div[data-remote],li[data-remote],button[data-remote],tr[data-remote]', function (e) {
    if (inNewTab(e)) {
      return;
    }
    // когда кликаем на ссылку без data-remote внутри элемента с data-remote,
    // то аякс запрос не должен отправляться на сервер - нужно дать браузеру перейти по ссылке
    if (e.target.tagName == 'A' && !$(e.target).data('remote')) {
      e.stopImmediatePropagation();
      return;
    }

    const $this = $(this);
    if ($this.attr('data-confirm') && !confirm($this.attr('data-confirm'))) {
      return false;
    }
    if ($this.callRemote() !== false) {
      e.preventDefault();
    }
  });

  /**
    * disable-with handlers
    */
  const disable_with_input_selector = 'input[data-disable-with]';
  const disable_with_form_remote_selector = 'form[data-remote]:has(' + disable_with_input_selector + ')';
  const disable_with_form_not_remote_selector = 'form:not([data-remote]):has(' + disable_with_input_selector + ')';

  const disable_with_input_function = function () {
    $(this).find(disable_with_input_selector).each(function () {
      const input = $(this);
      input.data('enable-with', input.val())
        .attr('value', input.attr('data-disable-with'))
        .attr('disabled', 'disabled');
    });
  };

  $(document).on('ajax:before', disable_with_form_remote_selector, disable_with_input_function);
  $(document).on('submit', disable_with_form_not_remote_selector, disable_with_input_function);

  $(document).on('ajax:complete', disable_with_form_remote_selector, function () {
    $(this).find(disable_with_input_selector).each(function () {
      const input = $(this);
      input.removeAttr('disabled')
        .val(input.data('enable-with'));
    });
  });
});


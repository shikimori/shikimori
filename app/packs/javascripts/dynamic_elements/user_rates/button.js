import delay from 'delay';
import { flash } from 'shiki-utils';
import { bind } from 'shiki-decorators';

import UserRatesTracker from '@/services/user_rates/tracker';
import View from '@/views/application/view';
import JST from '@/helpers/jst';

import * as AuthorizedAction from '../authorized_action';

const TEMPLATE = 'user_rates/button';
const I18N_KEY = 'activerecord.attributes.user_rate.statuses';

export default class UserRateButton extends View {
  initialize() {
    // data attribute is set in UserRatesTracker
    this.model = this.$root.data('model');
    this._render();

    // delegated handlers because @_render can be called multiple times
    this.on('click', '.trigger-arrow', this._toggleList);
    this.on('click', '.edit-trigger', this._toggleList);


    this.on('click', '.add-trigger', this._submitStatus);

    this.on('ajax:before', this._ajaxBefore);
    this.on('ajax:error', this._ajaxComplete);
    this.on('ajax:success', this._ajaxSuccess);
  }

  get isPersisted() {
    return !!this.model.id;
  }

  // handlers
  @bind
  async _toggleList() {
    this.$('.b-add_to_list').toggleClass('expanded');

    if (!this.$('.expanded-options').data('height')) {
      this.$('.expanded-options')
        .data('height', this.$('.expanded-options').height())
        .css('height', 0)
        .show();
    }

    await delay();

    const height = this.$('.b-add_to_list').hasClass('expanded') ?
      this.$('.expanded-options').data('height') :
      0;

    this.$('.expanded-options').css('height', height);
  }

  @bind
  _submitStatus(e) {
    const $form = $(e.target).closest('form');

    $form
      .find('input[name="user_rate[status]"]')
      .val($(e.currentTarget).data('status'));

    $form.submit();
  }

  @bind
  _ajaxBefore() {
    if (!window.SHIKI_USER.isSignedIn) {
      flash.info(I18n.t(`${AuthorizedAction.I18N_KEY}.register_to_complete_action`));
      return false;
    }

    this.$root.addClass('b-ajax');
  }

  @bind
  _ajaxComplete() {
    this.$root.removeClass('b-ajax');
  }

  @bind
  _ajaxSuccess(e, model) {
    UserRatesTracker.update(model || this._newUserRate());
    this._ajaxComplete();
  }

  // functions
  update(model) {
    this.model = model;
    this._render();
  }

  _render() {
    this
      .html(JST[TEMPLATE](this._renderParams()))
      .process();
  }

  _renderParams() {
    const submit_url = this.isPersisted ?
      `/api/v2/user_rates/${this.model.id}` :
      '/api/v2/user_rates';

    return {
      model: this.model,
      user_id: window.SHIKI_USER.id,
      statuses: I18n.t(`${I18N_KEY}.${this.model.target_type.toLowerCase()}`),
      form_url: submit_url,
      form_method: this.isPersisted ? 'PATCH' : 'POST',
      destroy_url: (this.isPersisted ? `/api/v2/user_rates/${this.model.id}` : undefined),
      extended_html: this._extendedHtml()
    };
  }

  _newUserRate() {
    return {
      status: 'planned',
      target_id: this.model.target_id,
      target_type: this.model.target_type
    };
  }

  // must be redefined in inherited class
  _extendedHtml() {}
}

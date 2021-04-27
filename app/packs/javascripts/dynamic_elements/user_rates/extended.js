import { bind } from 'shiki-decorators';

import JST from '@/helpers/jst';
import axios from '@/helpers/axios';
import UserRateButton from './button';

const EXTENDED_TEMPLATE = 'user_rates/extended';
const SCORE_TEMPLATE = 'user_rates/score';

export default class UserRateExtended extends UserRateButton {
  formHtml = null

  initialize() {
    this.entry = this.$root.data('entry');

    this.on('click', '.cancel', this._hideForm);

    this.on('ajax:success', '.remove', this._hideForm);
    this.on('ajax:success', '.rate-edit', this._hideForm);
    this.on('rate:change', this._changeScore);

    super.initialize();
  }

  // handlers
  @bind
  _toggleList({ currentTarget }) {
    if (this.isPersisted && currentTarget.classList.contains('edit-trigger')) {
      if (this.formHtml) {
        this._hideForm();
      } else {
        this._fetchForm();
      }
    } else {
      super._toggleList();
    }
  }

  @bind
  async _fetchForm() {
    this._ajaxBefore();
    const { data } = await axios.get(`/user_rates/${this.model.id}/edit`);

    this._ajaxComplete();
    this._showForm(data);
  }

  @bind
  _showForm(html) {
    this.formHtml = html;
    this._render();
    this.$('.remove.bottom').addClass('hidden');
    this.$('.delete-button.top').removeClass('hidden');
  }

  @bind
  _hideForm() {
    this.formHtml = null;
    this._render();
  }

  @bind
  _changeScore(e, score) {
    this.$('input[name="user_rate[score]"]').val(score);
    this.$('form').submit();
  }

  // functions
  _extendedHtml() {
    if (this.isPersisted) {
      return this.formHtml || this._renderExtended();
    }
  }

  _renderExtended() {
    return JST[EXTENDED_TEMPLATE]({
      entry: this.entry,
      model: this.model,
      increment_url: this._incrementUrl(),
      rate_html: JST[SCORE_TEMPLATE]({ score: this.model.score })
    });
  }

  _render() {
    super._render();
    this.$('.b-rate').rateable();
  }

  _incrementUrl() {
    if (this.isPersisted) {
      let suffix;

      if (this.model.volumes !== 0) {
        suffix = '?volumes';
      }

      return `/api/v2/user_rates/${this.model.id}/increment${suffix || ''}`;
    }
  }
}

import moment from 'moment';
import View from 'views/application/view';

const INPUT_FORMAT = 'YYYY-MM-DD';

export class DatePicker extends View {
  async initialize() {
    import(/* webpackChunkName: "pikaday" */ 'pikaday/scss/pikaday.scss');
    this.initPromise = import(/* webpackChunkName: "pikaday" */ 'vendor/async/pikaday')
      .then(Pikaday => this._initPicker(Pikaday.default));
  }

  async set(value, silent) {
    await this.initPromise;

    let inputValue;
    if (value) {
      inputValue = moment(value).format(INPUT_FORMAT);
    }
    this.root.value = inputValue;

    if (!silent) {
      this.$root.trigger('date:picked');
    }
  }

  _initPicker(Pikaday) {
    let initialValue;

    new Pikaday({
      field: this.root,
      onSelect: date => this.set(date),
      firstDay: 1,
      maxDate: new Date(),
      i18n: this._i18n()
    });

    // устанавливает после создания Pikaday, т.к. плагин перетирает значение
    // инпута и ставит дату в своём собственном форматировании,
    // а не в INPUT_FORMAT
    if (this.root.value) {
      initialValue = moment(this.root.value).toDate();
    }
    if (initialValue) {
      this.set(initialValue, true);
    }

    this.$root
      .on('keypress', e => {
        if (e.keyCode === 13) {
          this.$root.trigger('date:picked');
        }
      });
  }

  _i18n() {
    return {
      months: moment.months(),
      weekdays: moment.weekdays(),
      weekdaysShort: moment.weekdaysShort()
    };
  }
}

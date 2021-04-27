import $with from 'helpers/with';

export default class TrackUserRate {
  constructor(userRate, $container) {
    this._$node(userRate, $container)
      .data('model', userRate);
  }

  _$node(userRate, $container) {
    return $with(this.constructor.selector(userRate), $container);
  }

  static selector(userRate) {
    return `.b-user_rate.${userRate.target_type.toLowerCase()}-${userRate.target_id}`;
  }
}

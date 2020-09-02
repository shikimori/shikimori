import $with from 'helpers/with';

export default class TrackCatalogEntry {
  constructor(userRate, $container) {
    this._$node(userRate, $container)
      .data('model', userRate)
      .addClass(userRate.status);
  }

  _$node(userRate, $container) {
    return $with(this.constructor.selector(userRate), $container);
  }

  static selector(userRate) {
    return `.c-${userRate.target_type.toLowerCase()}.entry-${userRate.target_id}`;
  }
}

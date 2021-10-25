import $with from '@/utils/with';

export default class TrackReview {
  constructor(review, $root) {
    $with(this._selector(review), $root).data('model', review);
  }

  _selector(review) {
    return `.b-review#${review.id}`;
  }
}

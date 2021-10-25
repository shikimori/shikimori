import TrackReview from './track_review';

export default class ReviewsTracker {
  static track(JS_EXPORTS, $root) {
    if (Object.isEmpty(JS_EXPORTS != null ? JS_EXPORTS.reviews : undefined)) {
      return;
    }

    JS_EXPORTS.reviews.forEach(review => new TrackReview(review, $root));
    JS_EXPORTS.reviews = null;
  }
}

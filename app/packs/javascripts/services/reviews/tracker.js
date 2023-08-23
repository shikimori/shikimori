import TrackReview from './track_review';

export default class ReviewsTracker {
  static track(jsExports, $root) {
    if (Object.isEmpty(jsExports != null ? jsExports.reviews : undefined)) {
      return;
    }

    jsExports.reviews.forEach(review => new TrackReview(review, $root));
    jsExports.reviews = null;
  }
}

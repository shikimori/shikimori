import TrackTopic from './track_topic';

export default class TopicsTracker {
  static track(JS_EXPORTS, $root) {
    if (Object.isEmpty(JS_EXPORTS != null ? JS_EXPORTS.topics : undefined)) {
      return;
    }

    JS_EXPORTS.topics.forEach(topic => new TrackTopic(topic, $root));
    JS_EXPORTS.topics = null;
  }
}

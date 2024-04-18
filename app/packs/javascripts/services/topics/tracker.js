import isEmpty from 'lodash/isEmpty';

import TrackTopic from './track_topic';

export default class TopicsTracker {
  static track(jsExports, $root) {
    if (isEmpty(jsExports != null ? jsExports.topics : undefined)) {
      return;
    }

    jsExports.topics.forEach(topic => new TrackTopic(topic, $root));
    jsExports.topics = null;
  }
}

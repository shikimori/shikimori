import $with from '@/utils/with';

export default class TrackTopic {
  constructor(topic, $root) {
    $with(this._selector(topic), $root).data('model', topic);
  }

  _selector(topic) {
    return `.b-topic#${topic.id}`;
  }
}

import $with from '@/helpers/with';

export default class TrackComment {
  constructor(comment, $root) {
    $with(this._selector(comment), $root).data('model', comment);
  }

  _selector(comment) {
    return `.b-comment#${comment.id}`;
  }
}

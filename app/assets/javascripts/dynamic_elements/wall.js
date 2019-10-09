import ShikiView from 'views/application/shiki_view';
import WallView from 'views/wall/view';

export default class Wall extends ShikiView {
  initialize() {
    new WallView(this.$root);
  }
}

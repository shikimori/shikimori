import View from 'views/application/view';
import WallView from 'views/wall/view';

export default class Wall extends View {
  initialize() {
    new WallView(this.$root);
  }
}

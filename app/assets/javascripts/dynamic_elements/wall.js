import ShikiView from 'views/application/shiki_view';
import Wall from 'views/wall/view';

export default class WallView extends ShikiView {
  initialize() {
    new Wall(this.$root);
  }
}

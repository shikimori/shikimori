import View from 'views/application/view';

import GlobalSearch from './global';
// import CollectionSearch from './collection';

export default class SearchView extends View {
  initialize() {
    new GlobalSearch(this.$node);
  }
}

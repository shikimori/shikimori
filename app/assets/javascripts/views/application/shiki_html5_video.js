import { sessionStorage } from 'js-storage';
import View from 'views/application/view';

const VOLUME_KEY = 'video_volume';
const FULLSCREEN_EVENTS = 'webkitfullscreenchange mozfullscreenchange fullscreenchange';

export default class ShikiHtml5Video extends View {
  initialize() {
    this.root.volume = sessionStorage.get(VOLUME_KEY) || 1;

    // @on 'error', () => @error()
    this.on('click', () => this.click());
    this.on('volumechange', () => this.volumeChange());
    this.on(FULLSCREEN_EVENTS, e => this.switchFullscreen(e));
  }

  click() {
    if (this.root.paused) {
      this.root.play();
    } else {
      this.root.pause();
    }
    return false;
  }

  volumeChange() {
    sessionStorage.set(VOLUME_KEY, this.root.volume);
  }

  switchFullscreen(e) {
    if (document.fullscreenElement == this.root) {
      this.root.classList.add('fullscreen');
    } else {
      this.root.classList.remove('fullscreen');
    }
  }
}

import localStorage from 'local-storage';
import { bind } from 'shiki-decorators';
import View from 'views/application/view';

const VOLUME_KEY = 'video_volume';
const FULLSCREEN_EVENTS = 'webkitfullscreenchange mozfullscreenchange fullscreenchange';

export class ShikiHtml5Video extends View {
  initialize() {
    const storedVolume = localStorage(VOLUME_KEY);
    this.node.volume = storedVolume != null ? storedVolume : 1;

    // @on 'error', () => @error()
    this.on('click', this.click);
    this.on('volumechange', this.volumeChange);
    this.on(FULLSCREEN_EVENTS, this.switchFullscreen);
  }

  @bind
  click(e) {
    e.stopImmediatePropagation();
    e.preventDefault();

    if (this.node.paused) {
      this.node.play();
    } else {
      this.node.pause();
    }
  }

  @bind
  volumeChange() {
    localStorage(VOLUME_KEY, this.node.volume);
  }

  @bind
  switchFullscreen() {
    if (document.fullscreenElement === this.node) {
      this.node.classList.add('fullscreen');
    } else {
      this.node.classList.remove('fullscreen');
    }
  }
}

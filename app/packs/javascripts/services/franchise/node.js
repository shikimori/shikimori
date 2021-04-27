import d3 from 'd3';
import { memoize } from 'shiki-decorators'

import axios from 'helpers/axios';

const SELECT_SCALE = 2;
const BORDER_OFFSET = 3;

export class FranchiseNode {
  constructor(data, width, height, isCurrent) {
    this.width = width;
    this.height = height;
    this.isCurrent = isCurrent;

    Object.assign(this, data);

    this.selected = false;
    this.fixed = false;

    if (this.isCurrent) {
      this.width = (this.width * 1.3).ceil();
      this.height = (this.height * 1.3).ceil();
    }

    this.initialWidth = this.width;
    this.initialHeight = this.height;
    this._calcRs();
  }

  @memoize
  get d3Node() {
    return d3.select($(`.node#${this.id}`)[0]);
  }

  @memoize
  get d3ImageContainer() {
    return this.d3Node.selectAll('.image-container');
  }

  @memoize
  get d3Image() {
    return this.d3Node.selectAll('image');
  }

  @memoize
  get d3Year() {
    return this.d3Node.selectAll('.year');
  }

  @memoize
  get d3OuterBorder() {
    return this.d3Node.selectAll('path.border_outer');
  }

  @memoize
  get d3InnerBorder() {
    return this.d3Node.selectAll('path.border_inner');
  }

  deselect(boundX, boundY, tick) {
    this.selected = false;
    this.fixed = this.pfixed;

    this._hideTooltip();
    this._animate(this.initialWidth, this.initialHeight, boundX, boundY, tick);
  }

  select(boundX, boundY, tick) {
    this.selected = true;
    this.pfixed = this.fixed; // prior fixed
    this.fixed = true;

    this._loadTooltip();
    this._animate(
      this.initialWidth * SELECT_SCALE,
      this.initialHeight * SELECT_SCALE,
      boundX,
      boundY,
      tick
    );
  }

  yearX(w = this.width) {
    return w - 2;
  }

  yearY(h = this.height) {
    return h - 2;
  }

  _calcRs() {
    this.rx = this.width / 2.0;
    return this.ry = this.height / 2.0;
  }

  _animate(newWidth, newHeight, boundX, boundY, tick) {
    let ih;
    let io;
    let iw;

    if (this.selected) {
      io = d3.interpolate(0, BORDER_OFFSET);
      iw = d3.interpolate(this.width, newWidth);
      ih = d3.interpolate(this.height, newHeight);

      this.d3Node.attr({ class: 'node selected' });
    } else {
      io = d3.interpolate(BORDER_OFFSET, 0);
      iw = d3.interpolate(this.width - (BORDER_OFFSET * 2), newWidth);
      ih = d3.interpolate(this.height - (BORDER_OFFSET * 2), newHeight);

      this.d3Node.attr({ class: 'node' });
    }

    return this.d3Node
      .transition()
      .duration(500)
      .tween('animation', () => t => {
          // t = 1
        const o = io(t);
        const o2 = o * 2;
        const w = iw(t);
        const h = ih(t);

        const widthIncrement = (w + o2) - this.width;
        const heightIncrement = (h + o2) - this.height;

        this.width += widthIncrement;
        this.height += heightIncrement;

        this._calcRs();

        const outerBorderPath = `M 0,0 ${w + o2},0 ${w + o2},${h + o2} 0,${h + o2} 0,0`;

        this.d3Node.attr({
          transform: `translate(${boundX(this) - this.rx}, ${boundY(this) - this.ry})`
        });
        this.d3OuterBorder.attr({ d: outerBorderPath });
        this.d3ImageContainer.attr({ transform: `translate(${o}, ${o})` });
        this.d3InnerBorder.attr({ d: `M 0,0 ${w},0 ${w},${h} 0,${h} 0,0` });

        this.d3Image.attr({ width: w, height: h });
        this.d3Year.attr({ x: this.yearX(w), y: this.yearY(h) });

        return tick();
      });
  }

  _hideTooltip() {
    $('.sticky-tooltip').hide();
  }

  async _loadTooltip() {
    $('.sticky-tooltip').show().addClass('b-ajax');

    const { data } = await axios.get(this.url + '/tooltip');

    $('.sticky-tooltip').removeClass('b-ajax');
    $('.sticky-tooltip > .inner').html(data).process();
  }
}

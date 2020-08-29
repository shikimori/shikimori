/* eslint camelcase:0 */
export class ShikiMath {
  // detecting whether point is above or below a line
  // x,y - point
  // x1,y1 - point 1 of line
  // x2,y2 - point 2 of line
  static is_above(x, y, x1, y1, x2, y2) {
    const dx = x2 - x1;
    const dy = y2 - y1;

    return ((((dy * x) - (dx * y)) + (dx * y1)) - (dy * x1)) <= 0;
  }

  // detecting in which "sector" point x2,y2 is located accordingly to
  // rectangular node with center in x1,y1 and width=rx*2 and height=ry*2
  static sector(x1, y1, x2, y2, rx, ry) {
    // left_bottom to right_top
    const lb_to_rt = this.is_above(x2, y2, x1 - rx, y1 - ry, x1, y1);
    // left_top to right_bottom
    const lt_to_rb = this.is_above(x2, y2, x1 - rx, y1 + ry, x1, y1);

    if (lb_to_rt && lt_to_rb) {
      return 'top';
    } if (!lb_to_rt && lt_to_rb) {
      return 'right';
    } if (!lb_to_rt && !lt_to_rb) {
      return 'bottom';
    }
    return 'left';
  }

  // math for obtaining coords for link between two rectangular nodes
  // with center in xN,yN and width=rxN*2 and height=ryN*2
  static square_cutted_line(x1, y1, x2, y2, rx1, ry1, rx2, ry2) {
    let f_x1;
    let f_x2;
    let f_y1;
    let f_y2;
    const dx = x2 - x1;
    const dy = y2 - y1;

    const y = x => (((dy * x) + (dx * y1)) - (dy * x1)) / dx;
    const x = y => (((dx * y) - (dx * y1)) + (dy * x1)) / dy;

    const target_sector = this.sector(x1, y1, x2, y2, rx1, ry1);

    if (target_sector === 'right') {
      f_x1 = x1 + rx1;
      f_y1 = y(f_x1);

      f_x2 = x2 - rx2;
      f_y2 = y(f_x2);
    } else if (target_sector === 'left') {
      f_x1 = x1 - rx1;
      f_y1 = y(f_x1);

      f_x2 = x2 + rx2;
      f_y2 = y(f_x2);
    }

    if (target_sector === 'top') {
      f_y1 = y1 + ry1;
      f_x1 = x(f_y1);

      f_y2 = y2 - ry2;
      f_x2 = x(f_y2);
    }

    if (target_sector === 'bottom') {
      f_y1 = y1 - ry1;
      f_x1 = x(f_y1);

      f_y2 = y2 + ry2;
      f_x2 = x(f_y2);
    }

    return {
      x1: f_x1,
      y1: f_y1,
      x2: f_x2,
      y2: f_y2,
      sector: target_sector
    };
  }

  // tests for math
  static rspec() {
    // is_above
    this._assert(true, this.is_above(-1, 2, -1, -1, 1, 1));
    this._assert(true, this.is_above(0, 2, -1, -1, 1, 1));
    this._assert(true, this.is_above(0, 0, -1, -1, 1, 1));
    this._assert(true, this.is_above(1, 2, -1, -1, 1, 1));
    this._assert(false, this.is_above(2, 1, -1, -1, 1, 1));
    this._assert(false, this.is_above(-1, -2, -1, -1, 1, 1));

    // sector test
    this._assert('top', this.sector(0, 0, 0, 10, 1, 1));
    this._assert('top', this.sector(0, 0, 10, 10, 1, 1));
    this._assert('right', this.sector(0, 0, 10, 0, 1, 1));
    this._assert('right', this.sector(0, 0, 10, -10, 1, 1));
    this._assert('bottom', this.sector(0, 0, 0, -10, 1, 1));
    this._assert('left', this.sector(0, 0, -10, 0, 1, 1));

    // square_cutted_line
    this._assert(
      { x1: -9, y1: 0, x2: 9, y2: 0, sector: 'right' },
      this.square_cutted_line(-10, 0, 10, 0, 1, 1, 1, 1)
    );
    this._assert(
      { x1: 5, y1: 0, x2: -5, y2: 0, sector: 'left' },
      this.square_cutted_line(10, 0, -10, 0, 5, 1, 5, 1)
    );
    this._assert(
      { x1: 0, y1: 5, x2: 0, y2: -5, sector: 'bottom' },
      this.square_cutted_line(0, 10, 0, -10, 1, 5, 1, 5)
    );
    this._assert(
      { x1: 0, y1: -5, x2: 0, y2: 5, sector: 'top' },
      this.square_cutted_line(0, -10, 0, 10, 1, 5, 1, 5)
    );

    this._assert(
      { x1: 5, y1: 5, x2: -5, y2: -5, sector: 'left' },
      this.square_cutted_line(10, 10, -10, -10, 5, 5, 5, 5)
    );
    this._assert(
      { x1: 0.5, y1: 1, x2: 1.5, y2: 3, sector: 'top' },
      this.square_cutted_line(0, 0, 2, 4, 1, 1, 1, 1)
    );
  }

  static _assert(left, right) {
    if (JSON.stringify(left) !== JSON.stringify(right)) {
      throw `math error: expected ${JSON.stringify(left)}, got ${JSON.stringify(right)}`; // eslint-disable-line no-throw-literal
    }
  }
}

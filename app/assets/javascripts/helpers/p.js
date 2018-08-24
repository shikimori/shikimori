/* eslint-disable no-nested-ternary */

window.p = (number, ...args) => {
  const n = parseInt(number, 10);
  let plural = ((n % 10) === 1) && ((n % 100) !== 11) ?
    0 :
    ((n % 10) >= 2) && ((n % 10) <= 4) && (((n % 100) < 10) || ((n % 100) >= 20)) ?
      1 :
      2;
  plural = n === 0 ? 0 : plural;

  return args[plural];
};

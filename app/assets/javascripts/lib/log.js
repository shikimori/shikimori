function _log() {
  if ('console' in window && 'log' in console) {
    console.log.apply(console, arguments);
  }
}

function _warn() {
  if ('console' in window && 'warn' in console) {
    console.warn.apply(console, arguments);
  }
}

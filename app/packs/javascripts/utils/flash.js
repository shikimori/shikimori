export function pushFlash(message) {
  if (!('sessionStorage' in window)) { return; }

  sessionStorage.setItem('flashMessage', message);
}

export function popFlash() {
  if (!('sessionStorage' in window)) { return null; }

  const message = sessionStorage.getItem('flashMessage');
  sessionStorage.removeItem('flashMessage');
  return message;
}

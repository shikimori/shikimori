export default function preventEvent(e) {
  e.stopImmediatePropagation();
  e.preventDefault();
}

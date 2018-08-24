export default e =>
  (e.button === 1) || ((e.button === 0) && (e.ctrlKey || e.metaKey));

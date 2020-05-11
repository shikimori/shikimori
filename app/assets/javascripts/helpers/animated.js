import delay from 'delay';

export const ANIMATED_DELAY = 350;

export function animatedCollapse(element, isIgnorePaddings, isIgnoreMargins) {
  // get the height of the element's inner content, regardless of its actual size
  const sectionHeight = element.scrollHeight;

  // temporarily disable all css transitions
  const elementTransition = element.style.transition;
  element.style.transition = '';
  element.classList.add('animated-collapse');

  // on the next frame (as soon as the previous style change has taken effect),
  // explicitly set the element's height to its current pixel height, so we
  // aren't transitioning out of 'auto'
  requestAnimationFrame(() => {
    // may need to break animation if another animation has started
    // if (element.classList.contains('animated-collapse')) { return; }

    element.style.height = sectionHeight + 'px';
    element.style.transition = elementTransition;

    // on the next frame (as soon as the previous style change has taken effect),
    // have the element transition to height: 0
    requestAnimationFrame(async () => {
      element.style.height = '0px';

      if (!isIgnoreMargins) {
        element.style.marginTop = '0px';
        element.style.marginBottom = '0px';
      }

      if (!isIgnorePaddings) {
        element.style.paddingTop = '0px';
        element.style.paddingBottom = '0px';
      }

      await delay(ANIMATED_DELAY);

      element.style.height = '';

      if (!isIgnoreMargins) {
        element.style.marginTop = '';
        element.style.marginBottom = '';
      }

      if (!isIgnorePaddings) {
        element.style.paddingTop = '';
        element.style.paddingBottom = '';
      }

      element.classList.remove('animated-collapse');
      element.classList.add('hidden');
    });
  });
}
export function animatedExpand(element, isIgnorePaddings, isIgnoreMargins) {
  if (element.classList.contains('hidden')) {
    element.classList.remove('hidden');
  }

  // get the height of the element's inner content, regardless of its actual size
  const sectionHeight = element.scrollHeight;

  // temporarily disable all css transitions
  const elementTransition = element.style.transition;
  element.style.transition = '';
  element.classList.add('animated-expand');

  // on the next frame (as soon as the previous style change has taken effect),
  // explicitly set the element's height to its current pixel height, so we
  // aren't transitioning out of 'auto'
  requestAnimationFrame(() => {
    if (!element.style.height) { element.style.height = '0px'; }

    if (!isIgnorePaddings) {
      if (!element.style.paddingTop) { element.style.paddingTop = '0px'; }
      if (!element.style.paddingBottom) { element.style.paddingBottom = '0px'; }
    }

    if (!isIgnoreMargins) {
      if (!element.style.marginTop) { element.style.marginTop = '0px'; }
      if (!element.style.marginBottom) { element.style.marginBottom = '0px'; }
    }

    element.style.transition = elementTransition;

    // on the next frame (as soon as the previous style change has taken effect),
    // have the element transition to height: 0
    requestAnimationFrame(async () => {
      element.style.height = sectionHeight + 'px';

      await delay(ANIMATED_DELAY);

      element.style.height = '';

      if (!isIgnoreMargins) {
        element.style.marginTop = '';
        element.style.marginBottom = '';
      }

      if (!isIgnorePaddings) {
        element.style.paddingTop = '';
        element.style.paddingBottom = '';
      }

      element.classList.remove('animated-expand');
    });
  });
}

// https://css-tricks.com/using-css-transitions-auto-dimensions/
import delay from 'delay';

export const ANIMATED_DELAY = 350;

export function animatedCollapse(element) {
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
      element.style.paddingTop = '0px';
      element.style.paddingBottom = '0px';
      element.style.marginTop = '0px';
      element.style.marginBottom = '0px';

      await delay(ANIMATED_DELAY);

      element.style.height = '';
      element.style.paddingTop = '';
      element.style.paddingBottom = '';
      element.style.marginTop = '';
      element.style.marginBottom = '';

      element.classList.remove('animated-collapse');
      element.classList.add('hidden');
    });
  });

  return delay(ANIMATED_DELAY);
}
export function animatedExpand(element) {
  if (element.classList.contains('hidden')) {
    element.classList.remove('hidden');
  }

  // get the height of the element's inner content, regardless of its actual size
  const sectionHeight = element.scrollHeight;
  const { paddingTop, paddingBottom, marginTop, marginBottom } =
    getComputedStyle(element);

  // temporarily disable all css transitions
  const elementTransition = element.style.transition;
  element.style.transition = '';

  // on the next frame (as soon as the previous style change has taken effect),
  // explicitly set the element's height to its current pixel height, so we
  // aren't transitioning out of 'auto'
  requestAnimationFrame(() => {
    if (!element.style.height) { element.style.height = '0px'; }
    if (!element.style.paddingTop) { element.style.paddingTop = '0px'; }
    if (!element.style.paddingBottom) { element.style.paddingBottom = '0px'; }
    if (!element.style.marginTop) { element.style.marginTop = '0px'; }
    if (!element.style.marginBottom) { element.style.marginBottom = '0px'; }

    element.style.transition = elementTransition;

    requestAnimationFrame(() => {
      element.classList.add('animated-expand');

      // on the next frame (as soon as the previous style change has taken effect),
      // have the element transition to height: 0
      requestAnimationFrame(async () => {
        element.style.height = `${sectionHeight}px`;
        element.style.paddingTop = paddingTop;
        element.style.paddingBottom = paddingBottom;
        element.style.marginTop = marginTop;
        element.style.marginBottom = marginBottom;

        await delay(ANIMATED_DELAY);

        element.style.height = '';
        element.style.paddingTop = '';
        element.style.paddingBottom = '';
        element.style.marginTop = '';
        element.style.marginBottom = '';

        element.classList.remove('animated-expand');
      });
    });

    return delay(ANIMATED_DELAY);
  });
}

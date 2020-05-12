// https://css-tricks.com/using-css-transitions-auto-dimensions/
import delay from 'delay';

const ANIMATED_DELAY = 350;

let uniqId = 0;
const newId = () => uniqId += 1;
const animations = {};

export function animatedCollapse(element) {
  if (animations[element]) { cleanup(element); }

  const animationId = newId();
  animations[element] = animationId;

  // get the height of the element's inner content, regardless of its actual size
  const sectionHeight = element.scrollHeight;

  // temporarily disable all css transitions
  element.classList.add('animated-collapse');

  // on the next frame (as soon as the previous style change has taken effect),
  // explicitly set the element's height to its current pixel height, so we
  // aren't transitioning out of 'auto'
  requestAnimationFrame(() => {
    if (animations[element] !== animationId) { return; }

    // may need to break animation if another animation has started
    // if (element.classList.contains('animated-collapse')) { return; }

    element.style.height = sectionHeight + 'px';

    // on the next frame (as soon as the previous style change has taken effect),
    // have the element transition to height: 0
    requestAnimationFrame(async () => {
      if (animations[element] !== animationId) { return; }

      element.style.height = '0px';
      element.style.paddingTop = '0px';
      element.style.paddingBottom = '0px';
      element.style.marginTop = '0px';
      element.style.marginBottom = '0px';

      await delay(ANIMATED_DELAY);

      if (animations[element] !== animationId) { return; }
      cleanup(element);
      element.classList.add('hidden');
    });
  });

  return delay(ANIMATED_DELAY);
}

export function animatedExpand(element) {
  if (animations[element]) { cleanup(element); }

  const animationId = newId();
  animations[element] = animationId;

  if (element.classList.contains('hidden')) {
    element.classList.remove('hidden');
  }

  const sectionHeight = element.scrollHeight;
  const { paddingTop, paddingBottom, marginTop, marginBottom } =
    getComputedStyle(element);

  // on the next frame (as soon as the previous style change has taken effect),
  // explicitly set the element's height to its current pixel height, so we
  // aren't transitioning out of 'auto'
  requestAnimationFrame(() => {
    if (animations[element] !== animationId) { return; }

    if (!element.style.height) { element.style.height = '0px'; }
    if (!element.style.paddingTop) { element.style.paddingTop = '0px'; }
    if (!element.style.paddingBottom) { element.style.paddingBottom = '0px'; }
    if (!element.style.marginTop) { element.style.marginTop = '0px'; }
    if (!element.style.marginBottom) { element.style.marginBottom = '0px'; }

    requestAnimationFrame(() => {
      if (animations[element] !== animationId) { return; }

      element.classList.add('animated-expand');

      // on the next frame (as soon as the previous style change has taken effect),
      // have the element transition to height: 0
      requestAnimationFrame(async () => {
        if (animations[element] !== animationId) { return; }

        element.style.height = `${sectionHeight}px`;
        element.style.paddingTop = paddingTop;
        element.style.paddingBottom = paddingBottom;
        element.style.marginTop = marginTop;
        element.style.marginBottom = marginBottom;

        await delay(ANIMATED_DELAY);
        if (animations[element] !== animationId) { return; }

        cleanup(element);
      });
    });
  });

  return delay(ANIMATED_DELAY);
}

function cleanup(element) {
  console.log(element.style.height);

  element.style.height = '';
  element.style.paddingTop = '';
  element.style.paddingBottom = '';
  element.style.marginTop = '';
  element.style.marginBottom = '';

  if (element.classList.contains('animated-collapse')) {
    element.classList.remove('animated-collapse');
  } else {
    element.classList.remove('animated-expand');
  }

  delete animations[element];
}

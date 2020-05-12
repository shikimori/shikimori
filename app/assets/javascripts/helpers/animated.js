// based on https://css-tricks.com/using-css-transitions-auto-dimensions/
import delay from 'delay';

const ANIMATED_DELAY = 1000;

let uniqId = 0;
const newId = () => uniqId += 1;
const animations = {};

function buildAnimation(element) {
  const isInTransition = !!animations[element];

  if (element.classList.contains('hidden')) {
    element.classList.remove('hidden');
  }

  if (isInTransition) {
    cleanup(element);
  } else {
    const {
      paddingTop,
      paddingBottom,
      marginTop,
      marginBottom
    } = getComputedStyle(element);

    animations[element] = {
      paddingTop,
      paddingBottom,
      marginTop,
      marginBottom,
      scrollHeight: `${element.scrollHeight}px`
    };
  }

  animations[element].id = newId();
  animations[element].isInTransition = isInTransition;

  console.log(animations[element]);

  return animations[element];
}

export function animatedCollapse(element) {
  const animation = buildAnimation(element);

  element.classList.add('animated-collapse');

  if (animation.isInTransition) {
    transitionToCollapse(element, animation);
  } else {
    element.style.height = animation.scrollHeight;
    requestAnimationFrame(() => transitionToCollapse(element, animation));
  }

  return delay(ANIMATED_DELAY);
}

async function transitionToCollapse(element, animation) {
  if (animations[element]?.id !== animation.id) { return; }

  element.style.height = '0px';
  element.style.paddingTop = '0px';
  element.style.paddingBottom = '0px';
  element.style.marginTop = '0px';
  element.style.marginBottom = '0px';

  await delay(ANIMATED_DELAY);
  if (animations[element]?.id !== animation.id) { return; }

  element.classList.add('hidden');
  cleanup(element);
  delete animations[element];
}

export function animatedExpand(element) {
  const animation = buildAnimation(element);

  if (!element.style.height) { element.style.height = '0px'; }
  if (!element.style.paddingTop) { element.style.paddingTop = '0px'; }
  if (!element.style.paddingBottom) { element.style.paddingBottom = '0px'; }
  if (!element.style.marginTop) { element.style.marginTop = '0px'; }
  if (!element.style.marginBottom) { element.style.marginBottom = '0px'; }

  requestAnimationFrame(() => {
    if (animations[element]?.id !== animation.id) { return; }

    element.classList.add('animated-expand');

    requestAnimationFrame(async () => {
      if (animations[element]?.id !== animation.id) { return; }

      element.style.height = animation.scrollHeight;
      element.style.paddingTop = animation.paddingTop;
      element.style.paddingBottom = animation.paddingBottom;
      element.style.marginTop = animation.marginTop;
      element.style.marginBottom = animation.marginBottom;

      await delay(ANIMATED_DELAY);
      if (animations[element]?.id !== animation.id) { return; }

      cleanup(element);
      delete animations[element];
    });
  });

  return delay(ANIMATED_DELAY);
}

// async function transitionExpand(element, id) {
// }

function cleanup(element) {
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
}

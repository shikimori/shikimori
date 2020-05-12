// animation method inspired on https://css-tricks.com/using-css-transitions-auto-dimensions/
import delay from 'delay';

const ANIMATION_DURATION = 350;

let uniqId = 0;
const newId = () => uniqId += 1;
const animations = {};

function prepareAnimation(element) {
  const isInTransition = !!animations[element];

  if (element.classList.contains('hidden')) {
    element.classList.remove('hidden');
  }

  if (isInTransition) {
    cleanup(element);
    animations[element] = { ...animations[element] };
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
  const animation = prepareAnimation(element);
  console.log('animatedCollapse');

  element.classList.add('animated-collapse');

  if (animation.isInTransition) {
    transitionToCollapse(element, animation);
  } else {
    element.style.height = animation.scrollHeight;
    requestAnimationFrame(() => transitionToCollapse(element, animation));
  }

  return delay(ANIMATION_DURATION);
}

async function transitionToCollapse(element, animation) {
  if (animations[element]?.id !== animation.id) { return; }
  console.log('transitionToCollapse');

  element.style.height = '0px';
  element.style.paddingTop = '0px';
  element.style.paddingBottom = '0px';
  element.style.marginTop = '0px';
  element.style.marginBottom = '0px';

  await delay(ANIMATION_DURATION);
  if (animations[element]?.id !== animation.id) { return; }
  console.log('transitionToCollapse ANIMATION_DURATION');

  element.classList.add('hidden');
  cleanup(element);
  delete animations[element];
}

export function animatedExpand(element) {
  const animation = prepareAnimation(element);
  console.log('animatedExpand');

  if (!element.style.height) { element.style.height = '0px'; }
  if (!element.style.paddingTop) { element.style.paddingTop = '0px'; }
  if (!element.style.paddingBottom) { element.style.paddingBottom = '0px'; }
  if (!element.style.marginTop) { element.style.marginTop = '0px'; }
  if (!element.style.marginBottom) { element.style.marginBottom = '0px'; }

  if (animation.isInTransition) {
    element.classList.add('animated-expand');
    transitionToExpand(element, animation);
  } else {
    requestAnimationFrame(() => {
      if (animations[element]?.id !== animation.id) { return; }
      console.log('animatedExpand requestAnimationFrame');
      element.classList.add('animated-expand');

      requestAnimationFrame(() => transitionToExpand(element, animation));
    });
  }

  return delay(ANIMATION_DURATION);
}

async function transitionToExpand(element, animation) {
  if (animations[element]?.id !== animation.id) { return; }
  console.log('transitionToExpand');

  element.style.height = animation.scrollHeight;
  element.style.paddingTop = animation.paddingTop;
  element.style.paddingBottom = animation.paddingBottom;
  element.style.marginTop = animation.marginTop;
  element.style.marginBottom = animation.marginBottom;

  await delay(ANIMATION_DURATION);
  if (animations[element]?.id !== animation.id) { return; }
  console.log('transitionToExpand ANIMATION_DURATION');

  cleanup(element);
  delete animations[element];
}

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

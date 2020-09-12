// animation method inspired on https://css-tricks.com/using-css-transitions-auto-dimensions/
import delay from 'delay';
import newId from 'helpers/new_id';

const ANIMATION_DURATION = 350;
const animations = {};

function prepareAnimation(element) {
  if (!element._SHIKI_ID) {
    element._SHIKI_ID = newId();
  }

  const isInTransition = !!animations[element._SHIKI_ID];

  if (element.classList.contains('hidden')) {
    element.classList.remove('hidden');
  }

  if (isInTransition) {
    cleanup(element);
    animations[element._SHIKI_ID] = { ...animations[element._SHIKI_ID] };
  } else {
    const {
      paddingTop,
      paddingBottom,
      marginTop,
      marginBottom
    } = getComputedStyle(element);

    animations[element._SHIKI_ID] = {
      paddingTop,
      paddingBottom,
      marginTop,
      marginBottom,
      scrollHeight: `${element.scrollHeight}px`
    };
  }

  animations[element._SHIKI_ID].id = newId();
  animations[element._SHIKI_ID].isInTransition = isInTransition;

  return animations[element._SHIKI_ID];
}

export function animatedCollapse(element) {
  const animation = prepareAnimation(element);

  element.style.willChange = 'height, padding-top, padding-bottom, margin-top, margin-bottom';
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
  if (animations[element._SHIKI_ID]?.id !== animation.id) { return; }

  element.style.height = '0px';
  element.style.paddingTop = '0px';
  element.style.paddingBottom = '0px';
  element.style.marginTop = '0px';
  element.style.marginBottom = '0px';

  await delay(ANIMATION_DURATION);
  if (animations[element._SHIKI_ID]?.id !== animation.id) { return; }

  element.classList.add('hidden');
  cleanup(element);
  delete animations[element._SHIKI_ID];
}

export function animatedExpand(element) {
  const animation = prepareAnimation(element);

  if (!element.style.height) { element.style.height = '0px'; }
  if (!element.style.paddingTop) { element.style.paddingTop = '0px'; }
  if (!element.style.paddingBottom) { element.style.paddingBottom = '0px'; }
  if (!element.style.marginTop) { element.style.marginTop = '0px'; }
  if (!element.style.marginBottom) { element.style.marginBottom = '0px'; }

  if (animation.isInTransition) {
    element.classList.add('animated-expand');
    transitionToExpand(element, animation);
  } else {
    element.style.willChange = 'height, padding-top, padding-bottom, margin-top, margin-bottom';

    requestAnimationFrame(() => {
      if (animations[element._SHIKI_ID]?.id !== animation.id) { return; }
      element.classList.add('animated-expand');
      requestAnimationFrame(() => transitionToExpand(element, animation));
    });
  }

  return delay(ANIMATION_DURATION);
}

async function transitionToExpand(element, animation) {
  if (animations[element._SHIKI_ID]?.id !== animation.id) { return; }

  element.style.height = animation.scrollHeight;
  element.style.paddingTop = animation.paddingTop;
  element.style.paddingBottom = animation.paddingBottom;
  element.style.marginTop = animation.marginTop;
  element.style.marginBottom = animation.marginBottom;

  await delay(ANIMATION_DURATION);
  if (animations[element._SHIKI_ID]?.id !== animation.id) { return; }

  cleanup(element);
  delete animations[element._SHIKI_ID];
}

function cleanup(element) {
  element.style.height = '';
  element.style.paddingTop = '';
  element.style.paddingBottom = '';
  element.style.marginTop = '';
  element.style.marginBottom = '';
  element.style.willChange = '';

  if (element.classList.contains('animated-collapse')) {
    element.classList.remove('animated-collapse');
  } else {
    element.classList.remove('animated-expand');
  }
}
